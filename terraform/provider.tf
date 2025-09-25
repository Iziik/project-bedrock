terraform {
  required_version = ">= 1.2"
  required_providers {
    aws = { source = "hashicorp/aws" }
    kubernetes = { source = "hashicorp/kubernetes" }
  }
}
