resource "aws_apigatewayv2_api" "api" {
    name = "${var.project_name}-api"
    protocol_type = "HTTP"

    cors_configuration {
      allow_origins = [ "*" ]
      allow_methods = [ "GET", "POST", "OPTIONS" ]
      allow_headers = ["Content-Type", "Authorization"]
      max_age = 300
    }
}

resource "aws_cloudwatch_log_group" "api_access" {
  name = "${var.project_name}-api-access"
  retention_in_days = 30
}

# Integrations
resource "aws_apigatewayv2_integration" "create_order" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.create_order.invoke_arn
}

resource "aws_apigatewayv2_integration" "get_order" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.get_order.invoke_arn
}

# Routes
# JWT authorizer - attach to protect the endpoint
# Cognito - required to protect the endpoint
# Remove authorization_type and authorizer_id if you are not yet using Cognito - but be aware the API will be fully public.
resource "aws_apigatewayv2_route" "create_order" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /orders"
  target    = "integrations/${aws_apigatewayv2_integration.create_order.id}"

  authorization_type = var.enable_auth ? "JWT" : "NONE"
  authorizer_id      = var.enable_auth ? aws_apigatewayv2_authorizer.jwt.id : null
}

resource "aws_apigatewayv2_route" "get_order" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /orders/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.get_order.id}"

  authorization_type = var.enable_auth ? "JWT" : "NONE"
  authorizer_id      = var.enable_auth ? aws_apigatewayv2_authorizer.jwt.id : null
}

resource "aws_apigatewayv2_authorizer" "jwt" {
  api_id           = aws_apigatewayv2_api.api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "${var.project_name}-jwt-authorizer"

  jwt_configuration {
    audience = [var.cognito_client_id]
    issuer   = var.cognito_issuer_url
  }
}

# Stage
resource "aws_apigatewayv2_stage" "default" {
    api_id = aws_apigatewayv2_api.api.id
    name = "default"
    auto_deploy = true

    access_log_settings {
      destination_arn = aws_cloudwatch_log_group.api_access.arn
      format = jsonencode({
        requestId      = "$context.requestId"
        ip             = "$context.identity.sourceIp"
        httpMethod     = "$context.httpMethod"
        routeKey       = "$context.routeKey"
        status         = "$context.status"
        responseLength = "$context.responseLength"
        durationMs     = "$context.responseLatency"
        userAgent      = "$context.identity.userAgent"
      })
    }
}

# Lambda invoke permissions
resource "aws_lambda_permission" "apigw_create_order" {
  statement_id  = "AllowAPIGatewayInvokeCreateOrder"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_order.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_get_order" {
  statement_id  = "AllowAPIGatewayInvokeGetOrder"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_order.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}