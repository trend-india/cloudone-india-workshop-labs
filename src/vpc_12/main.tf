#Variables
#
#
#Main VPC
resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.name}"
    Environment = "${var.environment}"
    monaco      = "${var.name}"
    #"kubernetes.io/cluster/${var.code}" = "shared"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name        = "${var.name}"
    Environment = "${var.environment}"
    monaco      = "${var.name}"
  }
}

resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "main" {
  # Only create this if not using NAT instances.
  allocation_id = "${aws_eip.nat_gateway.id}"
  subnet_id     = "${aws_subnet.external.0.id}"
  depends_on    = ["aws_internet_gateway.main"]

  tags = {
    Name   = "${var.name}"
    monaco = "${var.name}"
  }
}

resource "aws_subnet" "internal" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${element(var.internal_subnets, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  count             = "${length(var.internal_subnets)}"

  tags = {
    Name        = "${var.name}-${format("internal-%03d", count.index + 1)}"
    Environment = "${var.environment}"
    monaco      = "${var.name}"
  }
}

locals {
  common_tags = "${map(
    "kubernetes.io/cluster/${var.code}", "shared"
  )}"
}

resource "aws_subnet" "external" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(var.external_subnets, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  count                   = "${length(var.external_subnets)}"
  map_public_ip_on_launch = true

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${var.name}-${format("external-%03d", count.index + 1)}",
      "Environment", "${var.environment}",
      "monaco", "${var.name}",
      "kubernetes.io/role/elb", "1"
    )
  )}"

  //  tags = {
  //    Name                                = "${var.name}-${format("external-%03d", count.index+1)}"
  //    Environment                         = "${var.environment}"
  //    monaco                              = "${var.name}"
  //    "kubernetes.io/role/elb"            = "1"
  //
  //    
  //  }
}

resource "aws_route_table" "external" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name        = "${var.name}-external-001"
    Environment = "${var.environment}"
    monaco      = "${var.name}"
  }
}

resource "aws_route" "external" {
  route_table_id         = "${aws_route_table.external.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

resource "aws_route_table" "internal" {
  count  = "${length(var.internal_subnets)}"
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name        = "${var.name}-${format("internal-%03d", count.index + 1)}"
    Environment = "${var.environment}"
    monaco      = "${var.name}"
  }
}

resource "aws_route" "internal" {
  # Create this only if using the NAT gateway service, vs. NAT instances.
  count                  = "${length(var.internal_subnets)}"
  route_table_id         = "${element(aws_route_table.internal.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.main.id}"
}

/**
 * Route associations
 */

resource "aws_route_table_association" "internal" {
  count          = "${length(var.internal_subnets)}"
  subnet_id      = "${element(aws_subnet.internal.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.internal.*.id, count.index)}"
}

resource "aws_route_table_association" "external" {
  count          = "${length(var.external_subnets)}"
  subnet_id      = "${element(aws_subnet.external.*.id, count.index)}"
  route_table_id = "${aws_route_table.external.id}"
}

#Internal Subnets
#External Subnets
#Nat Gateway
#IGW
#Route Associations
##
#
#resource "aws_flow_log" "flow_log" {
#  log_group_name = "${aws_cloudwatch_log_group.log_group.name}"
#  iam_role_arn   = "${aws_iam_role.log_group.arn}"
#  vpc_id         = "${aws_vpc.main.id}"
#  traffic_type   = "ALL"
#}
#
#resource "aws_cloudwatch_log_group" "log_group" {
#  name = "${aws_vpc.main.id}"
#}
#
#resource "aws_iam_role" "log_group" {
#  name                  = "role-${aws_vpc.main.id}"
#  force_detach_policies = "true"
#
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Sid": "",
#      "Effect": "Allow",
#      "Principal": {
#        "Service": "vpc-flow-logs.amazonaws.com"
#      },
#      "Action": "sts:AssumeRole"
#    }
#  ]
#}
#EOF
#}
#
#resource "aws_iam_role_policy" "vpc_log_flow" {
#  name = "policy-${aws_vpc.main.id}"
#  role = "${aws_iam_role.log_group.id}"
#
#  policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": [
#        "logs:CreateLogGroup",
#        "logs:CreateLogStream",
#        "logs:PutLogEvents",
#        "logs:DescribeLogGroups",
#        "logs:DescribeLogStreams"
#      ],
#      "Effect": "Allow",
#      "Resource": "*"
#    }
#  ]
#}
#EOF
#}
#

