module "vpc" {
  source      = "../vpc_12"
  name        = "${var.name}"
  environment = "${var.environment}"
  code        = "${var.code}"
}

module "dns" {
  source             = "../dns"
  name               = "${var.name}"
  public_r53_zone_id = "${var.public_r53_zone_id}"
  public_domain      = "${var.public_domain}"
  private_domain     = "bryceinternal.com"
  vpc_id             = "${module.vpc.id}"
}

#module "ecs" {
#  source = "../ecs"
#  name        = "${var.name}"
#  environment = "${var.environment}"
#  subnet_ids  = "${module.vpc.external_subnets}"
#  vpc_id      = "${module.vpc.id}"
#  admin_ips   = var.admin_ips
#  cidr        = "192.168.0.0/16"
#  dsmurl      = "dsm.brycehawk.com"
#  dsmpolicy = "13"
#}

