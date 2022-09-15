variable "public_r53_zone_id" {}
variable "public_domain" {}
variable "private_domain" {}
variable "vpc_id" {}

variable "name" {
  default = "vpc"
}

output "public_r53_zone_id" {
  value = "abcd"
}

output "private_r53_zone_id" {
  value = "${aws_route53_zone.private_zone.zone_id}"
}
