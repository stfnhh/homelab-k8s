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
  # checkov:skip=CKV_AWS_273: IAM user required for this integration; SSO not applicable

  name = local.name
}

resource "aws_iam_access_key" "iam_access_key" {
  user = aws_iam_user.iam_user.name
}

resource "aws_iam_user_policy" "iam_user_policy" {
  # checkov:skip=CKV_AWS_40: Inline user policy required for this integration

  user   = aws_iam_user.iam_user.name
  policy = data.aws_iam_policy_document.iam_policy_document.json
}
