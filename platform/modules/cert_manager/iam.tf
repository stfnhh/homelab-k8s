data "aws_iam_policy_document" "iam_policy_document" {
  statement {
    actions = [
      "route53:GetChange"
    ]
    resources = [
      "arn:aws:route53:::change/*"
    ]
  }
  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/${var.zone_id}"
    ]
  }
  statement {
    actions = [
      "route53:ListHostedZonesByName"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_user" "iam_user" {
  name = "k3s-letsencrypt"
}

resource "aws_iam_user_policy" "iam_user_policy" {
  name   = "k3s-letsencrypt"
  user   = aws_iam_user.iam_user.name
  policy = data.aws_iam_policy_document.iam_policy_document.json
}

resource "aws_iam_access_key" "iam_access_key" {
  user = aws_iam_user.iam_user.name
}
