resource "aws_sns_topic" "order_notifications" {
    name = "${var.project_name}-order-notifications"
}

resource "aws_sns_topic_subscription" "order_notifications_email" {
    topic_arn = aws_sns_topic.order_notifications.arn
    protocol  = "email"
    endpoint  = var.alert_email
}

resource "aws_sns_topic" "ops_alerts" {
    name = "${var.project_name}-ops-alerts"  
}

resource "aws_sns_topic_subscription" "ops_alerts_email" {
    topic_arn = aws_sns_topic.ops_alerts.arn
    protocol  = "email"
    endpoint  = var.alert_email  
}