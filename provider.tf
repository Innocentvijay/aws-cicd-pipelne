terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "${var.aws_region}"
  access_key = "AKIATOON7X34CL7JPV5O"
  secret_key = "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"
}
