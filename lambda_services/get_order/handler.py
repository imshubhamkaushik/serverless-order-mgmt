import json
import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["ORDERS_TABLE"])
    
def response(status, body):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body)
    }
    
def handler(event, context):
    try:
        path_params = event.get("pathParameters") or {}
        order_id = path_params.get("id")

        if not isinstance(order_id, str) or not order_id.strip():
            return response(400, {"error": "Missing order id in path"})
        
        logger.info(json.dumps({
            "message": "Fetching order",
            "order_id": order_id
        }))

        res = table.get_item(
            Key={"order_id": order_id},
        )
        
        item = res.get("Item")

        if not item:
            return response(404, {"message": "Order not found"})

        return response(200, item)

    except Exception:
        logger.error("Get order failed", exc_info=True)
        return response(500, {"error": "Internal server error"})
