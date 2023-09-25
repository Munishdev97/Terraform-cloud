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
  access_key = "AKIA5NNMYBVTDAEXLCZ4"         #var.aws_access_key_id
  secret_key = "jzU8IS09gL73wG3gWTtb7xfeqbickJM0iX4CP8z"    #var.aws_secret_access_key
}
