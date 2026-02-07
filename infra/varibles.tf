variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "Goshenignite"
}

variable "key_name" {
  type        = string
  description = "Existing EC2 KeyPair name for SSH (optional)."
  default     = ""
}
