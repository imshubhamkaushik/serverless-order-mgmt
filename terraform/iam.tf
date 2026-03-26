
# IAM Role for AWS Lambda Functions - Shared assume-role policy document 
# All three Lambdas use the same trust relationship but get separate roles and separate permission policies.
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# create_order role — may only send messages to the orders queue
resource "aws_iam_role" "create_order" {
  name               = "${var.project_name}-create-order-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "create_order_basic" {
  role       = aws_iam_role.create_order.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "create_order" {
  name = "${var.project_name}-create-order-policy"
  role = aws_iam_role.create_order.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "SendToOrdersQueue"
      Effect   = "Allow"
      Action   = ["sqs:SendMessage"]
      Resource = aws_sqs_queue.orders_queue.arn
    },
    {
      Sid = "WriteOrdersTable"
      Effect = "Allow"
      Action = ["dynamodb:PutItem"]
      Resource = aws_dynamodb_table.orders.arn
    }
    ]
  })
}

# get_order role — may only read items from the orders table
resource "aws_iam_role" "get_order" {
  name               = "${var.project_name}-get-order-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "get_order_basic" {
  role       = aws_iam_role.get_order.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "get_order" {
  name = "${var.project_name}-get-order-policy"
  role = aws_iam_role.get_order.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "ReadOrdersTable"
      Effect   = "Allow"
      Action   = ["dynamodb:GetItem"]
      Resource = aws_dynamodb_table.orders.arn
    }]
  })
}

# process_order role — may consume from SQS, write to DynamoDB, publish to SNS
resource "aws_iam_role" "process_order" {
  name               = "${var.project_name}-process-order-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "process_order_basic" {
  role       = aws_iam_role.process_order.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "process_order" {
  name = "${var.project_name}-process-order-policy"
  role = aws_iam_role.process_order.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ConsumeOrdersQueue"
        Effect = "Allow"
        # ReceiveMessage + DeleteMessage + GetQueueAttributes are all required
        # for Lambda event source mappings to function correctly
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
        ]
        Resource = aws_sqs_queue.orders_queue.arn
      },
      {
        Sid      = "WriteOrdersTable"
        Effect   = "Allow"
        Action   = ["dynamodb:UpdateItem"]
        Resource = aws_dynamodb_table.orders.arn
      },
      {
        Sid      = "PublishOrderNotifications"
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = aws_sns_topic.order_notifications.arn
      },
    ]
  })
}

# API Gateway CloudWatch role
resource "aws_iam_role" "apigw_cloudwatch" {
  name = "${var.project_name}-apigw-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "apigateway.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "apigw_cloudwatch" {
  role       = aws_iam_role.apigw_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# CAUTION: This is an account-level setting, not scoped to this API.
# There is only one aws_api_gateway_account per AWS account.
# Do not manage this here if other APIs in the same account already configure it.
resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.apigw_cloudwatch.arn
}