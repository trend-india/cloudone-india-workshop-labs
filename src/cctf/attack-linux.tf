#Protected 2012 with Linux
resource "aws_instance" "linux-attack" {
  ami           = var.ami_amzn
  instance_type = var.instance_size_linux_attack

  subnet_id                   = module.vpc.internal_subnets[0]
  vpc_security_group_ids      = ["${aws_security_group.all_internal.id}"]
  key_name                    = var.standard_key
  user_data                   = base64encode(file("${path.module}/user-data/attack-linux.sh"))
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name
  associate_public_ip_address = "false"
  #private_ip                  = "10.0.3.220"
  count                       = "${var.attacker_count ? 1 : 0}"

  tags = {
    Name                  = "${var.name}-attack-linux-${random_id.r.hex}"
    clone                 = var.name
    monaco_linux_attacker = "yes"
    project               = "monaco"
    #shutdown              = "nightly"
    attack_linux_code     = var.code
    monaco                = var.name
	answer				  = "ctf-flag"
  }
}
