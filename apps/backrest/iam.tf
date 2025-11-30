data "aws_iam_policy_document" "iam_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.s3_bucket.arn,
      "${aws_s3_bucket.s3_bucket.arn}/*",
    ]
  }
}

resource "aws_iam_user" "iam_user" {
  # checkov:skip=CKV_AWS_273:This IAM user is intentionally used for automated ACME DNS challenge authentication; SSO is not applicable
  name = local.name
}

resource "aws_iam_access_key" "iam_access_key" {
  user = aws_iam_user.iam_user.name
}

resource "aws_iam_user_policy" "iam_user_policy" {
  # checkov:skip=CKV_AWS_40:This inline user policy is required for ACME DNS challenge automation; attaching to a role or group is not possible for the workflow
  user   = aws_iam_user.iam_user.name
  policy = data.aws_iam_policy_document.iam_policy_document.json
}
