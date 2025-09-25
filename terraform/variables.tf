variable "aws_region" {
  type    = string
  default = "eu-west-2"
}
variable "cluster_name" {
  type    = string
  default = "bedrock-eks"
}
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnets CIDR"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "List of private subnets CIDR"
  type = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "azs" {
  description = "List of availability zones"
  type = list(string)
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}