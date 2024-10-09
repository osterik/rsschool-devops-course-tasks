terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  name = "${var.project_name}-${var.env_name}-${var.aws_region}"
}

#trivy:ignore:s3-bucket-logging:LOW: Bucket has logging disabled
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${local.name}-tfstate"
  lifecycle { prevent_destroy = true }
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#trivy:ignore:avd-aws-0132:HIGH: Bucket does not encrypt data with a customer managed key.
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#trivy:ignore:AVD-AWS-0024: MEDIUM: Point-in-time recovery is not enabled.
#trivy:ignore:AVD-AWS-0025: LOW: Table encryption does not use a customer-managed KMS key.
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${local.name}-tflocks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
