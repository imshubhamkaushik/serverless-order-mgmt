import json
import boto3
import os
import logging
from datetime import datetime, timezone
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

table = dynamodb.Table(os.environ["ORDERS_TABLE"])
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]

def handler(event, context):
    
    failed_items = []

    for record in event.get("Records", []):
        message_id = record["messageId"]
        try:
            logger.info(json.dumps({
                "message": "Processing record",
                "message_id": message_id
            }))
            
            body = json.loads(record["body"])
            order_id = body.get("order_id")
            
            if not order_id:
                raise ValueError("Missing order_id")
            
            timestamp = datetime.now(timezone.utc).isoformat()
            
            already_processed = False
            
            try:
                table.update_item(
                    Key={"order_id": order_id},
                    UpdateExpression="SET #s = :s, processed_at = :t",
                    ConditionExpression="attribute_not_exists(processed_at)",
                    ExpressionAttributeNames={"#s": "status"},
                    ExpressionAttributeValues={
                        ":s": "PROCESSED",
                        ":t": timestamp
                    },
                )
            except ClientError as e:
                if e.response["Error"]["Code"] == "ConditionalCheckFailedException":
                    logger.info(json.dumps({
                        "message": "Order already processed",
                        "order_id": order_id
                    }))
                    already_processed = True
                else:
                    raise
            if not already_processed:
                sns.publish(
                    TopicArn=SNS_TOPIC_ARN,
                    Subject=f"Order {order_id} processed",
                    Message=json.dumps({
                        "order_id": order_id,
                        "status": "PROCESSED"
                    })
                )
            
                logger.info(json.dumps({
                    "message": "Order Processed",
                    "order_id": order_id
                }))

        except Exception:
            logger.error(json.dumps({
                "message": "Failed to process order",
                "message_id": message_id
            }), exc_info=True)
            
            failed_items.append({
                "itemIdentifier": message_id
            })

    raise ValueError("Failed to process items")