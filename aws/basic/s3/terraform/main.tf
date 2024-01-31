terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

variable bucketName {
  type        = string
  default     = ""
  description = "description"
}


resource "aws_s3_bucket" "s3bucket" {
  bucket = var.bucketName
}