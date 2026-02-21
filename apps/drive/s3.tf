resource "aws_s3_bucket" "s3_bucket" {
  # checkov:skip=CKV_AWS_144: Cross-region replication is not required for this bucket
  # checkov:skip=CKV_AWS_21: Versioning not required for this bucket
  # checkov:skip=CKV_AWS_18: Access logging not required
  # checkov:skip=CKV2_AWS_62: Event notifications not required
  # checkov:skip=CKV_AWS_145: SSE-S3 (AES256) is intentionally used to avoid excessive KMS request costs for high-frequency backup workloads

  bucket        = "sabio-casa-${local.name}"
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_server_side_encryption_configuration" {
  # checkov:skip=CKV_AWS_145: SSE-S3 (AES256) is intentionally used to avoid excessive KMS request costs for high-frequency backup workloads

  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_ownership_controls" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_bucket_lifecycle_configuration" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    id     = "lifecycle"
    status = "Enabled"

    transition {
      days          = 1
      storage_class = "GLACIER_IR"
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 3
    }
  }
}


