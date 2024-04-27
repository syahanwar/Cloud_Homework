# Terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
  }
}

#Provider
provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
}