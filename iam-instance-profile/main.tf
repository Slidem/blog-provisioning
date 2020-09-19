# ec2 instance will assume an iam role
resource "aws_iam_role" "ec2_role" {
  name               = var.role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}
# iam policies will be attached to the ec2 role
resource "aws_iam_policy_attachment" "ec2_policy_attachment" {

  for_each = toset(var.iam_policies_arn)

  name       = "blog-instance-policy-attachments"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "blog_instance_profile" {
  name = "blog-instance-profile"
  role = aws_iam_role.ec2_role.name
}

