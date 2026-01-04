output "s3_bucket" {
  value       = aws_s3_bucket.s3_bucket.bucket
  description = "S3 Bucket Name"
}

output "aws_access_key_id" {
  value       = aws_iam_access_key.iam_access_key.id
  sensitive   = true
  description = "AWS Access Key ID"
}

output "aws_secret_access_key" {
  value       = aws_iam_access_key.iam_access_key.secret
  sensitive   = true
  description = "AWS Secret Access Key"
}
