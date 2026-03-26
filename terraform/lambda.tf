# Archive sources
data "archive_file" "create_order_zip" {
    type = "zip"
    source_dir = "${path.module}/../lambda_services/create_order"
    output_path = "${path.module}/../create_order.zip"
}

data "archive_file" "process_order_zip" {
    type = "zip"
    source_dir = "${path.module}/../lambda_services/process_order"
    output_path = "${path.module}/../process_order.zip"
}

data "archive_file" "get_order_zip" {
    type = "zip"
    source_dir = "${path.module}/../lambda_services/get_order"
    output_path = "${path.module}/../get_order.zip"
}

# Lambda functions
# create_order
resource "aws_lambda_function" "create_order" {
    function_name = "${var.project_name}-create-order"
    handler = "handler.handler"  
    runtime = "python3.11"
    role = aws_iam_role.create_order.arn

    filename = data.archive_file.create_order_zip.output_path

    source_code_hash = data.archive_file.create_order_zip.output_base64sha256

    timeout = 30
    memory_size = 256

    environment {
      variables = {
        ORDERS_TABLE = aws_dynamodb_table.orders.name
        ORDERS_QUEUE_URL = aws_sqs_queue.orders_queue.url
      }
    }
}

# process_order
resource "aws_lambda_function" "process_order" {
    function_name = "${var.project_name}-process-order"
    handler = "handler.handler"  
    runtime = "python3.11"
    role = aws_iam_role.process_order.arn

    filename = data.archive_file.process_order_zip.output_path

    source_code_hash = data.archive_file.process_order_zip.output_base64sha256

    timeout = 30
    memory_size = 256

    environment {
      variables = {
        ORDERS_TABLE = aws_dynamodb_table.orders.name
        SNS_TOPIC_ARN = aws_sns_topic.order_notifications.arn
      }
    }

}

# get_order
resource "aws_lambda_function" "get_order" {
    function_name = "${var.project_name}-get-order"
    handler = "handler.handler"  
    runtime = "python3.11"
    role = aws_iam_role.get_order.arn

    filename = data.archive_file.get_order_zip.output_path

    source_code_hash = data.archive_file.get_order_zip.output_base64sha256

    timeout = 30
    memory_size = 256

    environment {
      variables = {
        ORDERS_TABLE = aws_dynamodb_table.orders.name
      }
    }

}

# SQS to process_order event source mapping
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
    event_source_arn = aws_sqs_queue.orders_queue.arn
    function_name = aws_lambda_function.process_order.arn
    function_response_types = ["ReportBatchItemFailures"]
    batch_size = 10
}