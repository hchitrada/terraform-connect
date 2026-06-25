output "state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform remote state storage"
  value       = aws_s3_bucket.state.id
}

output "lock_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking"
  value       = aws_dynamodb_table.lock.name
}

output "connection_arn" {
  description = "ARN of the CodeStar Connection to the Git provider"
  value       = aws_codestarconnections_connection.this.arn
}
