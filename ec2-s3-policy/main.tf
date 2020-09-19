data "aws_iam_policy_document" "s3_access_policy" {

  statement {
    actions = [
      "s3:*"
    ]

    resources = [for bucket_name in var.buckets : "arn:aws:s3:::${bucket_name}/*"]
  }
}

resource "aws_iam_policy" "s3_policy" {
  name        = "blog_instance_s3_policy"
  path        = "/"
  description = "Blog instances s3 policy"
  policy      = data.aws_iam_policy_document.s3_access_policy.json
}