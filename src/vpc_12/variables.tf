variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Environment tag, e.g prod"
  default     = "prod"
}

variable "name" {
  description = "Name tag, e.g stack"
  default     = "vpc"
}

variable "code" {
  description = "Name tag, e.g stack"
  default     = "bryce"
}

variable "external_subnets" {
  description = "List of external subnets"
  type        = list
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.5.0/24"]
}

variable "internal_subnets" {
  description = "List of internal subnets"
  type        = list
  default     = ["10.0.3.0/24", "10.0.4.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "admin_ips" {
  description = "List of Administrator IPs"
  type        = list
  default     = ["10.0.0.0/16"]
}

#Variables
#
#
#Main VPC
#Internal Subnets
#External Subnets
#Nat Gateway
#IGW
#Route Associations
#

