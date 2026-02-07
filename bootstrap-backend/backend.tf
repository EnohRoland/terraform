terraform {
  backend "s3" {
    bucket  = "goshenignite-terraform-state-enoh"
    key     = "bootstrap/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
