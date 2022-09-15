resource "aws_instance" "jenkins" {
  #ami           = "${var.ami_amzn}"
  ami           = var.ami_jenkins
  instance_type = var.instance_size_devops
  subnet_id     = "${random_shuffle.internal_subnets.result[0]}"
  #subnet_id              = random_shuffle.jenkins_subnet.result
  vpc_security_group_ids = ["${aws_security_group.all_internal.id}"]

  #user_data                   = data.template_file.jenkins_lab.rendered
  user_data                   = base64encode(file("${path.module}/user-data/jenkins.sh"))
  iam_instance_profile        = "${aws_iam_instance_profile.instance_profile.name}"
  associate_public_ip_address = "false"
  key_name                    = var.standard_key
  count                       = "${var.jenkins_count ? 1 : 0}"

  tags = {
    Name                  = "jenkins.bryceinternal.com"
    clone                 = "${var.name}"
    monaco_linux_attacker = "yes"
    project               = "monaco"
	answer				  = "ctf-flag"
    #shutdown              = "nightly"
    gitlab_code           = "${var.code}"
    monaco                = "${var.name}"
  }
}

resource "aws_route53_record" "jenkins" {
  zone_id = module.dns.private_r53_zone_id
  name    = "jenkins"
  type    = "A"
  ttl     = "30"
  count   = "${var.jenkins_count ? 1 : 0}"
  records = [
    "${aws_instance.jenkins[count.index].private_ip}"
  ]
}
