
resource "aws_instance" "win2008" {
  ami           = var.ami_2008
  instance_type = var.instance_size_2008
  key_name      = var.standard_key

  user_data            = base64encode(file("${path.module}/user-data/win2008.ps1"))
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"

  subnet_id              = "${random_shuffle.internal_subnets.result[0]}"
  vpc_security_group_ids = ["${aws_security_group.all_internal.id}"]
  count   = "${var.victim_count ? 1 : 0}"

  root_block_device {
    volume_size = "50"
    volume_type = "gp2"
  }

  tags = {
    Name           = "win2008.bryceinternal.com"
    Hostname       = "win2008.bryceinternal.com"
    enable_ssm     = "true"
    clone          = "${var.name}"
    techdemo_d     = "yes"
    project        = "techdemo"
    inside_man     = "steve"
	answer		   = "ctf-flag"
    #shutdown       = "nightly"
    bill_reset     = "yes"
    victim_ds_code = "${var.code}"
    monaco         = "${var.name}"
  }
}

resource "aws_route53_record" "win2008" {
  zone_id = module.dns.private_r53_zone_id
  name    = "win2008"
  type    = "A"
  ttl     = "30"
  count   = "${var.victim_count ? 1 : 0}"

  records = [
    "${aws_instance.win2008[count.index].private_ip}"
  ]
}
