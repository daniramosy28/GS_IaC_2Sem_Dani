terraform {
      backend "s3" {
    bucket         = "tf-state-gsiacdani"
    key            = "path/to/terraform.tfstate"
    dynamodb_table = "tf-state-gsiacdani"
    region         = "us-east-1"
  }
}