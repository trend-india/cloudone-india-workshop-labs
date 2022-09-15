data "aws_ami" "windows2019" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["801119661308"] # Canonical
}

resource "aws_instance" "bastion" {
  # ami                    = "${data.aws_ami.windows2019.id}"
  #ami                    = "ami-0331481cc4fdd340b" Default
  #ami                    = "ami-04cd26f365c39bb6f"
  #ami                     = "ami-0742289d9db1c740b"
  ami                     = "ami-05758bf34345e7523"
  instance_type          = var.instance_size_bastion
  subnet_id              = random_shuffle.external_subnets.result[0]
  vpc_security_group_ids = [aws_security_group.bastion.id]
  #user_data              = templatefile("${path.module}/user-data/bastion2.ps1", { dsmurl = "dsm.brycehawk.com", dsmpolicy = "16", code = "${var.code}", aws_key = "${aws_iam_access_key.user.id}", aws_secret = "${aws_iam_access_key.user.secret}", aws_username = "${aws_iam_access_key.user.user}", codecommit_ssh_id = "${aws_iam_user_ssh_key.user.ssh_public_key_id}", aws_password = "pw" })
  user_data              = templatefile("${path.module}/user-data/bastion.ps1",{code = "${var.code}", aws_key = "${aws_iam_access_key.user.id}", aws_secret = "${aws_iam_access_key.user.secret}", aws_username = "${aws_iam_access_key.user.user}", codecommit_ssh_id = "${aws_iam_user_ssh_key.user.ssh_public_key_id}", aws_password = "pw", s3_bucket_monaco_dashboard = "${var.s3_bucket_monaco_dashboard}" , s3_bucket_monaco_tools = "${var.s3_bucket_monaco_tools}" ,  aws_region = "${var.aws_region}"})
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  root_block_device {
    volume_size = "100"
  }

  tags = {
    Name         = "${var.name}-bastion-${random_id.r.hex}"
    enable_ssm   = "true"
    clone        = var.name
    project      = "techdemo"
    #shutdown     = "nightly"
    bastion_code = var.code
    monaco       = var.name
    bastion      = "yes"
	answer		 = "ctf-flag"
  }
}


resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  depends_on = [module.vpc.IGW_main]
  vpc      = true
}

resource "aws_route53_record" "pub-ns" {
  zone_id = var.public_r53_zone_id
  name    = var.code
  type    = "A"
  ttl     = "30"

  records = [
    aws_eip.bastion.public_ip,
  ]
}
resource "aws_route53_record" "bastion" {
  zone_id = module.dns.private_r53_zone_id
  name    = "bastion"
  type    = "A"
  ttl     = "30"

  records = [
    aws_instance.bastion.private_ip
  ]
}
