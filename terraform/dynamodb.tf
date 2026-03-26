resource "aws_dynamodb_table" "orders" {
  name = "${var.project_name}-orders"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "order_id"
    
  attribute {
    name = "order_id"
    type = "S"
  } 

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }
}