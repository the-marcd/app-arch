
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
    region = "us-east-2"
    profile = "temprole"
}

variable "azs" {
    type = list
    default = ["us-east-2b,us-east-2c"]
}