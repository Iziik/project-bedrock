resource "aws_dynamodb_table" "carts" {
  name         = var.carts_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "cartId"

  attribute {
    name = "cartId"
    type = "S"
  }
}
