terraform {
  backend "s3" {
    bucket         = "goshenignite-tfstate-e8bb83f9"

    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "goshenignite-tflock"
    encrypt        = true
  }
}
