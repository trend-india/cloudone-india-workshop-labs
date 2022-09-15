variable "unique_id" {
  type        = string
  description = "A unique string that will be prepended to Name tags for all craeated resources"
}


variable "key_pair" {
  type        = string
  description = "The name of the keypair you will use to connect to the instances.  This keypair must exist in the region"
  default     = "cloudone-india-john" #Change that Key Pair
}


variable "struts_port" {
  type        = string
  description = "Port that struts listens on"
  default     = "8080"
}

variable "dvwa_port" {
  type        = string
  description = "port that Damn Vulnerable Web App listens on"
  default     = "80"
}

variable "my_pub_ip" {
  type        = string
  description = "My Public IP Address"
  default     = "0.0.0.0/0"
}


variable "types" {
  type = map(string)
  default = {
    bastion     = "t3.medium"
    attacker    = "t3.micro"
    work        = "t3.micro"
  }
}

variable "inet_vpc" {
  type = map(string)
  default = {
    #Internet VPC Defaults
    cidr          = "10.0.0.0/16"
    name          = "Inet VPC"
    desc          = "Internet VPC"
    pub_sub1_cidr  = "10.0.1.0/24"
    pub_sub1_name  = "Internet VPC Public Subnet 1"
    mgmt_sub1_cidr = "10.0.0.0/24"
    mgmt_sub1_name = "Internet VPC Management Subnet 1"
    prot_sub1_cidr  = "10.0.2.0/24"
    prot_sub1_name  = "Internet VPC Protected Subnet 1"
    pub_sub2_cidr  = "10.0.4.0/24"
    pub_sub2_name  = "Internet VPC Public Subnet 2"
    mgmt_sub2_cidr = "10.0.3.0/24"
    mgmt_sub2_name = "Internet VPC Management Subnet 2"
    prot_sub2_cidr  = "10.0.5.0/24"
    prot_sub2_name  = "Internet VPC Protected Subnet 2"
  }
}

variable "attacker_vpc" {
  type = map(string)
  default = {
    #Attacker VPC Defaults
    cidr            = "172.21.0.0/16"
    name            = "Attacker VPC"
    desc            = "Attacker VPC"
    pub_sub1_cidr   = "172.21.0.0/24"
    pub_sub1_name   = "Attacker VPC Public Subnet 1"
  }
}


variable "network_count" {
  default = "0"
}

variable "public_r53_zone_id" {}
