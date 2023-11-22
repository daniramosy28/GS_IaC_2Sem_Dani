terraform {
      backend "s3" {
    bucket         = "tf-state-GS-IacDani"
    key            = "path/to/terraform.tfstate"
    dynamodb_table = "tf-state-GS-IaCDani"
    region         = "us-east-1"
  }
}