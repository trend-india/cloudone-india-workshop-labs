data "aws_ami" "dsm" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-7.3_HVM_GA-20161026-x86_64-1-Hourly2-GP2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["309956199498"] #amazon
}

resource "random_id" "db_pw" {
  byte_length = 8
}

data "template_file" "user_data" {
  template = "${file("${path.module}/dsm_copy_user_data.sh")}"

}

resource "random_shuffle" "dsm_subnet" {
  input        = module.vpc.internal_subnets
  result_count = 1
  count        = "1"
}


resource "aws_instance" "dsm" {
  ami = "ami-0f41230feaaf8d98d"
  #ami                    = "${data.aws_ami.dsm.id}"
  instance_type          = "t2.large"
  key_name               = "cc-john"
  subnet_id              = "${random_shuffle.dsm_subnet[count.index].result[0]}"
  vpc_security_group_ids = ["${aws_security_group.all_internal.id}"]
  user_data              = "${data.template_file.user_data.rendered}"
  iam_instance_profile   = "${aws_iam_instance_profile.instance_profile.name}"

  count   = "${var.dsm_count ? 1 : 0}"

  root_block_device {
    volume_size = "250"
    volume_type = "gp2"
  }

  tags = {
    Name          = "${var.name}-dsm-${random_id.r.hex}"
    Environment   = "${var.environment}"
    enable_ssm    = "true"
    clone         = "${var.name}"
    cloned        = "true"
    project       = "techdemo"
    endpoint_wipe = "yes"
	answer		  = "ctf-flag"
    #shutdown      = "nightly"
    dsm_code      = "${var.code}"
    monaco        = "${var.name}"
  }
}

resource "aws_route53_record" "dsm" {
  zone_id = "${module.dns.private_r53_zone_id}"
  name    = "dsm"
  type    = "A"
  ttl     = "30"
  count   = "${var.dsm_count ? 1 : 0}"

  records = [
    "${aws_instance.dsm[count.index].private_ip}",
  ]
}

#
#resource "aws_iam_role_policy_attachment" "dsm_ssm" {
#  role       = "${aws_iam_role.dsm_role.name}"
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
#}
#
#resource "aws_iam_role" "dsm_role" {
#  name                  = "dsm-${random_id.r.hex}"
#  force_detach_policies = "true"
#
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": "sts:AssumeRole",
#      "Principal": {
#        "Service": "ec2.amazonaws.com"
#      },
#      "Effect": "Allow",
#      "Sid": ""
#    }
#  ]
#}
#EOF
#}
#
#resource "aws_iam_instance_profile" "dsm_profile" {
#  name = "dsm-${random_id.r.hex}"
#  role = "${aws_iam_role.dsm_role.name}"
#}
#
#resource "aws_iam_role_policy" "dsm_policy" {
#  name = "${var.name}-${random_id.r.hex}"
#  role = "${aws_iam_role.dsm_role.id}"
#
#  policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": [
#        "ec2:Describe*",
#        "sns:publish*",
#        "iam:ListAccountAliases",
#        "s3:get*",
#        "kms:Encrypt",
#        "kms:Decrypt",
#        "kms:ReEncrypt*",
#        "kms:GenerateDataKey*",
#        "kms:DescribeKey",
#        "iam:ListUsers",
#        "iam:ListSSHPublicKeys",
#        "iam:GetSSHPublicKey",
#        "workspaces:DescribeWorkspaces",
#        "workspaces:DescribeWorkspaceDirectories",
#        "workspaces:DescribeWorkspaceBundles",
#        "workspaces:DescribeTags"
#      ],
#      "Effect": "Allow",
#      "Resource": "*"
#    }
#  ]
#}
#EOF
#}
#

