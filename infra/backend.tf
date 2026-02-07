terraform {
  backend "s3" {
    bucket         = "REPLACE_ME_BUCKET"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "REPLACE_ME_TABLE"
    encrypt        = true
  }
}
