# 🛒 Serverless Order Management System (OMS)

A simple **event-driven serverless application** built on AWS to manage order creation, processing, and retrieval.

This project demonstrates core **DevOps + cloud fundamentals** using AWS services like Lambda, API Gateway, SQS, DynamoDB, SNS, and Terraform.

---

# 📌 Architecture Overview

```
Client → API Gateway (JWT Auth)
       → Create Order Lambda
       → SQS Queue
       → Process Order Lambda
       → DynamoDB
       → SNS (Notifications)

Client → API Gateway → Get Order Lambda → DynamoDB
```

---

# 🚀 Features

* Create orders via REST API
* Asynchronous order processing using SQS
* Order status tracking in DynamoDB
* Notification on order processing via SNS
* Secure endpoints using JWT (Cognito)
* Infrastructure provisioned using Terraform

---

# 🧰 Tech Stack

### ☁️ AWS Services

* API Gateway (HTTP API)
* AWS Lambda
* Amazon SQS
* Amazon DynamoDB
* Amazon SNS
* Amazon Cognito (JWT Authentication)
* CloudWatch (logs & alarms)

### ⚙️ Infrastructure

* Terraform (Infrastructure as Code)

### 🐍 Backend

* Python (Boto3)

---

# 📂 Project Structure

```
.
├── create_order/
│   └── handler.py
├── process_order/
│   └── handler.py
├── get_order/
│   └── handler.py
├── terraform/
│   ├── apigateway.tf
│   ├── lambda.tf
│   ├── sqs.tf
│   ├── dynamodb.tf
│   ├── sns.tf
│   ├── iam.tf
│   ├── cloudwatch.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── outputs.tf
└── README.md
```

---

# ⚙️ How It Works

## 1️⃣ Create Order

* API Gateway receives request
* Lambda validates input and stores order in DynamoDB
* Message is pushed to SQS for async processing

## 2️⃣ Process Order

* Lambda is triggered by SQS
* Updates order status to `PROCESSED`
* Publishes notification to SNS

## 3️⃣ Get Order

* Fetches order details from DynamoDB using order_id

---

# 🔐 Authentication

* API is secured using **JWT Authorizer (Cognito)**
* Requests must include a valid JWT token
* Unauthorized requests are rejected at API Gateway

---

# 🧪 Sample API Requests

## Create Order

```bash
POST /orders

{
  "customer_id": "cust-123",
  "product": "laptop",
  "quantity": 1
}
```

---

## Get Order

```bash
GET /orders/{order_id}
```

---

# 🏗️ Infrastructure Setup

## Prerequisites

* AWS CLI configured
* Terraform installed (>= 1.10)

---

## Deploy

```bash
cd terraform

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

---

# 📊 Monitoring

* CloudWatch Logs for Lambda execution
* Basic CloudWatch Alarms for:

  * Lambda errors
  * Queue failures

---

# ⚠️ Limitations

* No advanced retry strategy
* No strict idempotency guarantees
* Basic error handling
* Designed for learning/demo purposes

---

# 🎯 Learning Outcomes

This project demonstrates:

* Event-driven architecture
* Asynchronous processing using SQS
* Serverless application design
* Infrastructure as Code with Terraform
* Basic monitoring and alerting
* API security using JWT

---

# 📌 Future Improvements

* Add DLQ (Dead Letter Queue) for failed messages
* Implement idempotency handling
* Improve error handling and retries
* Add CI/CD pipeline (GitHub Actions / Jenkins)
* Add API rate limiting and throttling
