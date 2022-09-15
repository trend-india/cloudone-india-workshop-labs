resource "aws_iam_role_policy_attachment" "instance_ssm" {
  role       = "${aws_iam_role.instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role" "instance_role" {
  name                  = "monaco-${var.name}"
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

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${random_id.r.hex}-${var.name}"
  role = "${aws_iam_role.instance_role.name}"
}

resource "aws_iam_role_policy" "role_policy" {
  name = "${random_id.r.hex}"
  role = "${aws_iam_role.instance_role.id}"

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
        }
    ]
}
EOF
}


resource "aws_iam_user" "user" {
  name = "my-${var.name}"

  tags = {
    monaco = "${var.name}"
  }
}


resource "aws_iam_user_ssh_key" "user" {
  username   = "${aws_iam_user.user.name}"
  encoding   = "SSH"
  public_key = "ssh-rsa ${var.public_key} ${var.standard_key}"
}

resource "aws_iam_access_key" "user" {
  user = "${aws_iam_user.user.name}"
}

#resource "aws_iam_user_login_profile" "user" {
#  user    = "${aws_iam_user.user.name}"
#  pgp_key = "zKgq9iM5X8TzZ1a24HT6A2UZ62aw927W"
#}
#
#output "password" {
#  value = "${aws_iam_user_login_profile.user.encrypted_password}"
#}

data "aws_caller_identity" "current" {}

#resource "aws_iam_role_policy_attachment" "user_policy_instance_role" {
#  role       = "${aws_iam_role.instance_role.name}"
#  policy_arn = "${aws_iam_policy.user_policy.arn}"
#}
#
#resource "aws_iam_user_policy_attachment" "user_policy_user" {
#  user       = "${aws_iam_user.user.name}"
#  policy_arn = "${aws_iam_policy.user_policy.arn}"
#}


resource "aws_iam_policy" "user_policy" {
  name        = "monaco-${var.name}-main"
  description = "Policy for Everything"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": [
              "ec2:Describe*",
              "ec2:StopInstances",
              "ec2:RebootInstances"
          ],
          "Condition": {
              "StringEquals": {
                  "ec2:ResourceTag/monaco": "${var.name}"
              }
          },
          "Resource": "*",
          "Effect": "Allow"
      },
      {
          "Sid": "EKS",
          "Effect": "Allow",
          "Action": "eks:*",
          "Resource": [
             "arn:aws:eks:ap-southeast-1:${data.aws_caller_identity.current.account_id}:cluster/${var.code}",
             "arn:aws:eks:ap-southeast-1:${data.aws_caller_identity.current.account_id}:cluster/monaco-*"
          ]
      },
	  {
          "Sid": "S3",
          "Effect": "Allow",
          "Action": "s3:*",
          "Resource": "*"
      },
	  {
          "Sid": "CF",
          "Effect": "Allow",
          "Action": "cloudformation:*",
          "Resource": "*"
      },
      {
        "Sid": "cloudconnector",
        "Action": [
            "ec2:DescribeImages",
            "ec2:DescribeInstances",
            "ec2:DescribeRegions",
            "ec2:DescribeSubnets",
            "ec2:DescribeTags",
            "ec2:DescribeVpcs",
            "ec2:DescribeAvailabilityZones",
            "ec2:DescribeSecurityGroups",
            "workspaces:DescribeWorkspaces",
            "workspaces:DescribeWorkspaceDirectories",
            "workspaces:DescribeWorkspaceBundles",
            "workspaces:DescribeTags",
            "iam:ListAccountAliases",
            "iam:GetRole",
            "iam:GetRolePolicy",
            "sts:AssumeRole",
            "sns:Publish"
        ],
        "Effect": "Allow",
        "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": [
              
              "ecr:GetAuthorizationToken"
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": "ecr:*",
          "Resource": "arn:aws:ecr:ap-southeast-1:${data.aws_caller_identity.current.account_id}:repository/${var.name}-grapefruit"
      },
      {
          "Effect": "Allow",
          "Action": "ecr:*",
          "Resource": "arn:aws:ecr:ap-southeast-1:${data.aws_caller_identity.current.account_id}:repository/${var.name}-melon"
      },
      {
          "Effect": "Allow",
          "Action": "codecommit:ListRepositories",
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": "codecommit:*",
          "Resource": "arn:aws:codecommit:ap-southeast-1:${data.aws_caller_identity.current.account_id}:${var.name}-grapefruit"
      },
      {
          "Effect": "Allow",
          "Action": "codecommit:*",
          "Resource": "arn:aws:codecommit:ap-southeast-1:${data.aws_caller_identity.current.account_id}:${var.name}-melon"
      },
	  {
          "Effect": "Allow",
          "Action": "codecommit:*",
          "Resource": "arn:aws:codecommit:ap-southeast-1:${data.aws_caller_identity.current.account_id}:${var.name}-CC-Template-Scanner"
      },
	  {
          "Sid": "Serverless",
          "Effect": "Allow",
          "Action": [
                "codecommit:GetTree",
                "codecommit:ListPullRequests",
                "codecommit:GetBlob",
                "codecommit:GetReferences",
                "codecommit:ListRepositories",
                "codecommit:GetPullRequestApprovalStates",
                "codecommit:DescribeMergeConflicts",
                "codecommit:ListTagsForResource",
                "codecommit:BatchDescribeMergeConflicts",
                "codecommit:GetCommentsForComparedCommit",
                "codecommit:GetCommit",
                "codecommit:GetComment",
                "codecommit:GetCommitHistory",
                "codecommit:GetCommitsFromMergeBase",
                "codecommit:GetApprovalRuleTemplate",
                "codecommit:BatchGetCommits",
                "codecommit:DescribePullRequestEvents",
                "codecommit:GetPullRequest",
                "codecommit:ListAssociatedApprovalRuleTemplatesForRepository",
                "codecommit:ListBranches",
                "codecommit:GetPullRequestOverrideState",
                "codecommit:GetRepositoryTriggers",
                "codecommit:ListApprovalRuleTemplates",
                "codecommit:GitPull",
                "codecommit:BatchGetRepositories",
                "codecommit:GetCommentsForPullRequest",
                "codecommit:GetObjectIdentifier",
                "codecommit:CancelUploadArchive",
                "codecommit:GetFolder",
                "codecommit:BatchGetPullRequests",
                "codecommit:GetFile",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:ListRepositoriesForApprovalRuleTemplate",
                "codecommit:EvaluatePullRequestApprovalRules",
                "codecommit:GetDifferences",
                "codecommit:GetRepository",
                "codecommit:GetBranch",
                "codecommit:GetMergeConflicts",
                "codecommit:GetMergeCommit",
                "codecommit:GetMergeOptions"
            ],
            "Resource": "arn:aws:codecommit:ap-southeast-1:${data.aws_caller_identity.current.account_id}:uploader-serverless"
        }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "policy_attachment" {
  #name  = "${var.name}"
  user = "${aws_iam_user.user.name}"
  #roles = ["${aws_iam_role.instance_role.name}"]
  #depends_on = ["aws_iam_policy.user_policy"]
  # groups     = ["${aws_iam_group.group.name}"]
  policy_arn = "${aws_iam_policy.user_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  #name  = "${var.name}"
  role = "${aws_iam_role.instance_role.name}"
  #roles = ["${aws_iam_role.instance_role.name}"]
  #depends_on = ["aws_iam_policy.user_policy"]
  # groups     = ["${aws_iam_group.group.name}"]
  policy_arn = "${aws_iam_policy.user_policy.arn}"
}