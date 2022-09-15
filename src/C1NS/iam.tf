resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.unique_id}"
  role = aws_iam_role.instance_role.name
}


resource "aws_iam_role_policy_attachment" "instance_ssm" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role" "instance_role" {
  name                  = "${var.unique_id}"
  force_detach_policies = "true"

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


resource "aws_iam_role_policy" "role_policy" {
  name = "${var.unique_id}"
  role = aws_iam_role.instance_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
{
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "kms:Decrypt",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::*/*",
                "arn:aws:s3:::bryce-installers",
                "arn:aws:kms:*:*:key/f9512d2a-0a26-4267-a7d3-c9427548b678"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:HeadBucket"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:AttachRolePolicy"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}