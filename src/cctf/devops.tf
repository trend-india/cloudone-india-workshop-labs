resource "aws_instance" "devops" {
  ami           = "${var.ami_amzn_devops}"
  instance_type = var.instance_size_bastion
  key_name      = var.standard_key

  subnet_id                   = "${random_shuffle.internal_subnets.result[0]}"
  vpc_security_group_ids      = ["${aws_security_group.devops.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.instance_profile.name}"
  user_data                   = templatefile("${path.module}/user-data/devops.sh", {name = "${var.name}" , s3_bucket_monaco_code = "${var.s3_bucket_monaco_code}" ,  iam_user_codecommit_https_git_credentials_username = "${var.iam_user_codecommit_https_git_credentials_username}", iam_user_codecommit_https_git_credentials_password = "${var.iam_user_codecommit_https_git_credentials_password}" , aws_region = "${var.aws_region}",  aws_account_id = "${var.aws_account_id}"})
  associate_public_ip_address = "false"
  count                       = "${var.devops_count ? 1 : 0}"

  root_block_device {
    volume_size = "50"
  }

//depends_on = ["aws_codecommit_repository.melon", "aws_codecommit_repository.grapefruit", "aws_ecr_repository.melon", "aws_ecr_repository.grapefruit"]
  depends_on = ["aws_codecommit_repository.melon", "aws_ecr_repository.melon"]

  tags = {
    Name                  = "devops.bryceinternal.com"
    clone                 = "${var.name}"
    monaco_linux_attacker = "yes"
    project               = "monaco"
	answer				  = "ctf-flag"
    #shutdown              = "nightly"
    gitlab_code           = "${var.code}"
    monaco                = "${var.name}"
	#attack_linux_code     = var.code
  }
}
resource "aws_route53_record" "devops" {
  zone_id = "${module.dns.private_r53_zone_id}"
  name    = "devops"
  type    = "A"
  ttl     = "30"
  count   = "${var.devops_count ? 1 : 0}"

  records = [
    "${aws_instance.devops[count.index].private_ip}",
  ]
}
