terraform {
  backend "s3" {
    bucket        = "terraform-buckets-s3"
    key           = "env:/terraform.tfstate"
    region        = "eu-west-2"
    use_lockfile  = true
  }
}



provider "aws" {
  region = var.aws_region
}
