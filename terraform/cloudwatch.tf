# CloudWatch Alarms

# DQ depth - any message landing here means a processing failure
resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
    alarm_name = "${var.project_name}-dlq-not-empty"
    alarm_description = "Messages have arrived in the dead-letter queue - check process_order logs"
    namespace = "AWS/SQS"
    metric_name = "ApproximateNumberOfMessagesVisible"
    dimensions = { QueueName = aws_sqs_queue.orders_dlq.name }
    statistic = "Sum"
    period = 60
    evaluation_periods = 1
    threshold = 0
    comparison_operator = "GreaterThanThreshold"
    treat_missing_data = "notBreaching"
    alarm_actions = [aws_sns_topic.ops_alerts.arn]
}

# Lambda error rate alarms
resource "aws_cloudwatch_metric_alarm" "create_order_errors" {
    alarm_name = "${var.project_name}-create-order-errors"
    alarm_description = "create_order Lambda error rate is elevated"
    namespace = "AWS/Lambda"
    metric_name = "Errors"
    dimensions = { FunctionName = aws_lambda_function.create_order.function_name }
    statistic = "Sum"
    period = 60
    evaluation_periods = 1
    threshold = 1
    comparison_operator = "GreaterThanOrEqualToThreshold"
    treat_missing_data = "notBreaching"
    alarm_actions = [aws_sns_topic.ops_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "get_order_errors" {
    alarm_name = "${var.project_name}-get-order-errors"
    alarm_description = "get_order Lambda error rate is elevated"
    namespace = "AWS/Lambda"
    metric_name = "Errors"
    dimensions = { FunctionName = aws_lambda_function.get_order.function_name }
    statistic = "Sum"
    period = 60
    evaluation_periods = 1
    threshold = 1
    comparison_operator = "GreaterThanOrEqualToThreshold"
    treat_missing_data = "notBreaching"
    alarm_actions = [aws_sns_topic.ops_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "process_order_errors" {
    alarm_name = "${var.project_name}-process-order-errors"
    alarm_description = "process_order Lambda error rate is elevated"
    namespace = "AWS/Lambda"
    metric_name = "Errors"
    dimensions = { FunctionName = aws_lambda_function.process_order.function_name }
    statistic = "Sum"
    period = 60
    evaluation_periods = 1
    threshold = 1
    comparison_operator = "GreaterThanOrEqualToThreshold"
    treat_missing_data = "notBreaching"
    alarm_actions = [aws_sns_topic.ops_alerts.arn]
}

# API Gateway 5xx errors
resource "aws_cloudwatch_metric_alarm" "api_5xx" {
    alarm_name = "${var.project_name}-api-5xx"
    alarm_description = "API Gateway is returning 5xx responses"
    namespace = "AWS/ApiGateway"
    metric_name = "5XXError"
    dimensions = {
        ApiId = aws_apigatewayv2_api.api.id
        Stage = aws_apigatewayv2_stage.default.name
    }
    statistic = "Sum"
    period = 60
    evaluation_periods = 1
    threshold = 1
    comparison_operator = "GreaterThanOrEqualToThreshold"
    treat_missing_data = "notBreaching"
    alarm_actions = [aws_sns_topic.ops_alerts.arn] 
}