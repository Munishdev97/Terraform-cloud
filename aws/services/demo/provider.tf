terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.17.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}
