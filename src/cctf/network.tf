resource "random_shuffle" "internal_subnets" {
  input        = module.vpc.internal_subnets
  result_count = 1
}

resource "random_shuffle" "external_subnets" {
  input        = module.vpc.external_subnets
  result_count = 1
}


resource "aws_security_group" "all_internal" {
  name        = "${var.name}-internal-${random_id.r.hex}"
  description = "${var.name}-internal-${random_id.r.hex}"
  vpc_id      = "${module.vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.admin_ips
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name}-internal-${random_id.r.hex}"
    Environment = "${var.environment}"
    project     = "techdemo"
    monaco      = "${var.name}"
  }
}

resource "aws_security_group" "devops" {
  name        = "${var.name}-devops-${random_id.r.hex}"
  description = "${var.name}-devops-${random_id.r.hex}"
  vpc_id      = "${module.vpc.id}"



  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = var.cidr
  }
  
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = var.cidr
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
     security_groups = ["${aws_security_group.all_internal.id}"]
  }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name}-devops-${random_id.r.hex}"
    Environment = "${var.environment}"
    project     = "techdemo"
    monaco      = "${var.name}"
  }
}


resource "aws_security_group" "bastion" {
  name        = "${var.name}-bastion-${random_id.r.hex}"
  description = "${var.name}-bastion-${random_id.r.hex}"
  vpc_id      = "${module.vpc.id}"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name}-bastion-${random_id.r.hex}"
    Environment = "${var.environment}"
    monaco      = "${var.name}"
  }
}

