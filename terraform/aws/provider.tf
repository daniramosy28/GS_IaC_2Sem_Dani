terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.23"
    }
  }
  
}

provider "aws" {
  region = "us-east-1"
}