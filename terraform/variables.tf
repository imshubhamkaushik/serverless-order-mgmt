variable "project_name" {
    description = "Project Name Prefixed to all resource names"
    default = "serverless-order-mgmt"
}

variable "aws_region" {
    description = "AWS Region to deploy into"
    default = "ap-south-1"
}

# Cognito - supply these via a .tfvars file or environment variables
variable "cognito_client_id" {
    description = "Cognito User Pool App Client ID used as the JWT audience"
    type = string  
}

variable "cognito_issuer_url" {
    description = "Cognito User Pool issuer URL (https://cognito-idp.<region>.amazonaws.com/<pool-id>)"
    type = string
}

variable "enable_auth" {
    description = "Enable authentication"
    type = bool
    default = true  
}

variable "alert_email" {
    description = "Email address to receive alerts"
    type = string
    default = "your-team@example.com" # update this  
}