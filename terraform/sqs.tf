resource "aws_sqs_queue" "orders_dlq" {
    name = "${var.project_name}-orders-dlq"

    sqs_managed_sse_enabled = true
}

resource "aws_sqs_queue" "orders_queue" {
    name = "${var.project_name}-orders-queue"

    visibility_timeout_seconds = 180
    message_retention_seconds = 1209600

    sqs_managed_sse_enabled = true

    redrive_policy = jsonencode({
      deadLetterTargetArn = aws_sqs_queue.orders_dlq.arn
      maxReceiveCount    = 3
    })
}