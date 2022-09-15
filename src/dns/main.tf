resource "aws_route53_zone" "private_zone" {
  name          = "${var.private_domain}"
  force_destroy = "true"
  #vpc        = ["${var.vpc_id}"]
  vpc {
    vpc_id = "${var.vpc_id}"
  }
  comment = "DNS for ${var.name}"

  tags = {
    Name = "${var.name}"
  }
}
