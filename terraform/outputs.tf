output "api_endpoint" {
    description = "Base URL for API endpoint"
    value = aws_apigatewayv2_stage.default.invoke_url
}