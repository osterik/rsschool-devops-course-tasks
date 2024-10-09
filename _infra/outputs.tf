output "tfstate_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.id
  description = "The name of the S3 bucket"
}

output "tflocks_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}

output "github_oidc_role_arn" {
  value       = aws_iam_role.github_oidc.arn
  description = "ARN of role to assume for GitHub Action"
}
