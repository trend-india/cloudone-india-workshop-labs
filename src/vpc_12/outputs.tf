output "id" {
  value = "${aws_vpc.main.id}"
}

// The VPC CIDR
output "cidr_block" {
  value = "${aws_vpc.main.cidr_block}"
}

// The VPC CIDR
output "IGW_main" {
  value = "${aws_internet_gateway.main}"
}

// A comma-separated list of subnet IDs.
output "external_subnets" {
  value = aws_subnet.external.*.id
}

// A list of subnet IDs.
output "internal_subnets" {
  value = aws_subnet.internal.*.id
}

// The default VPC security group ID.
//output "security_group" {
//  value = "${aws_vpc.main.default_security_group_id}"
//}

// The list of availability zones of the VPC.
output "availability_zones" {
  #type  = list(string)
  value = ["${aws_subnet.external.*.availability_zone}"]
}

// The external route table ID.
output "external_rtb_id" {
  value = "${aws_route_table.external.id}"
}

// The list of EIPs associated with the internal subnets.
//output "internal_nat_ips" {
//  value = ["${aws_eip.nat.*.public_ip}"]
//}

