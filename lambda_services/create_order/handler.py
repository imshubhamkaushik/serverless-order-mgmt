import json
import boto3
import uuid
import os
import logging
from datetime import datetime, timezone

logger = logging.getLogger()
logger.setLevel(logging.INFO)

sqs = boto3.client('sqs')
dynamodb = boto3.resource('dynamodb')

ORDERS_TABLE = os.environ["ORDERS_TABLE"]
QUEUE_URL = os.environ["ORDERS_QUEUE_URL"]

table = dynamodb.Table(ORDERS_TABLE)

# REQUIRED_FIELDS = ["customer_id", "product", "quantity"]

def response(status, body):
    
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body)
    }
    
def handler (event, context):
    
    try:
        body = json.loads(event.get("body", "{}"))

        product = body.get("product")
        quantity = body.get("quantity")
        customer_id = body.get("customer_id")
        
        # Validation
        if not isinstance(product, str) or not product.strip():
            return response(400, {"error": "Product is required"})

        if not isinstance(quantity, int) or quantity <=0:
            return response(400, {"error": "Invalid Quantity. Must be a positive number"})
        
        if not isinstance(customer_id, str) or not customer_id.strip():
            return response(400, {"error": "Invalid Customer ID"})
            
        order_id = str(uuid.uuid4())
        timestamp = datetime.now(timezone.utc).isoformat()
        
        order = {
            "order_id": order_id,
            "customer_id": customer_id,
            "product": product,
            "quantity": quantity,
            "status": "PENDING",
            "created_at": timestamp,
        }
        
        table.put_item(
            Item=order
        )
        
        # Send message to SQS (decoupled processing)
        sqs.send_message(
            QueueUrl = QUEUE_URL,
            MessageBody = json.dumps(order)
        )
        
        logger.info(json.dumps({
            "message": "Order Created",
            "order_id": order_id,
            "request_id": context.aws_request_id
        }))
        
        return response(202, order)
        
    except json.JSONDecodeError:
        return response(400, {"message": "Invalid JSON body"})
    
    except Exception:
        logger.error("Create order failed", exc_info=True)
        return response(500, {"message": "Internal server error"})