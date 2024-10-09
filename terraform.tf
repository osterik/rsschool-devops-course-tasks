terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }

  backend "s3" {
    bucket         = "osterik-rsschool-dev-eu-central-1-tfstate"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "osterik-rsschool-dev-eu-central-1-tflocks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
