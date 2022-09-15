variable "environment" {
  description = "Environment tag, e.g prod"
  default     = "prod"
}

# Modifying "workshop-labs\src\cctf\user-data\bastion.ps1"
# Line 7
variable "s3_bucket_monaco_dashboard" {
  default = "cloudone-india-monaco-dashboard"
}

# Line 8
variable "s3_bucket_monaco_tools" {
  default = "cloudone-india-monaco-tools"
}


# Modifying "workshop-labs\src\cctf\user-data\devops.sh"
# Lines 10, 14, 26, 27, 31, 32, 34, 42, 54, 55, 59, 60, 62, and 63
variable "aws_region" {
  default = "ap-southeast-1"
}

# Lines 11, 18, 36, and 46
variable "s3_bucket_monaco_code" {
  default = "cloudone-india-monaco-code"
}

# Lines 14, 34, and 42
# Insert the “HTTPS Git credentials for AWS CodeCommit” for the IAM User “codecommit user”
# Username
variable "iam_user_codecommit_https_git_credentials_username" {
  default = "cloudone-india-codecommit-at-665977444369"
}

# Password
variable "iam_user_codecommit_https_git_credentials_password" {
  default = "GQ0BTFREZ3XNYcz1uvSX/a/vfsfQ4ECoQFxp/vhFCQ0="
}

# Lines 26, 27, 31, 32, 54, 55, 59, 60, 62, and 63
variable "aws_account_id" {
  default = "665977444369"
}

variable "standard_key" {
  default = "cloudone-india-john"
}

variable "public_key" {
  default = "AAAAB3NzaC1yc2EAAAADAQABAAABAQCU3GpooEkgGs4mC6mmiU9jSRVvi9u6ilbunJF4l6YwcwycstgJwW4Vs4NSMCAoiEKqTC4xhiPWCU96XBIVTAWDHE4wxv77rgCL/CTz3S3Yr34zOrcjYf7TatEyNK0QXk28i4vSMqs+9Yjow10iDopP1qfTGamvEsoSXwRNKuMghY9o1q3G8vyqJQm1LqlMlpsOPEPKD2RUMaNMGoDkpe2kYXM61DFUMEIhzDrdlujvMu01hN3mj1BAWlEdFIsHIXxCLJDhrsLaqaLqrzHIUXGSIew7/ExJ+bQEdyeQP9HS9yh2M4M3bq4xFplsgg3aGbYakRq+7o9LK73q2mO3XAFv"
}




variable "ami_2008" {
  # default = "ami-0aecc51fb06542c34"
  # default = "ami-08dd1da8b0fd24a88"  This AMI is shared from Trend SEA
  default = "ami-07c3faf0b76248f40"
}

variable "instance_size_2008" {
  default = "t2.medium"
}

variable "instance_size_bastion" {
  default = "t3.medium"
}
variable "instance_size_devops" {
  default = "t3.micro"
}

variable "instance_size_linux_attack" {
  default = "t3.micro"
}

variable "instance_size_dsm" {
  default = "t2.medium"
}

variable "ami_bastion" {
  default = "ami-024f1051ad385755a"
}

variable "ami_dsm" {
  default = "ami-07448938dfc595674"
}

variable "ami_amzn" {
  # default = "ami-05b3bcf7f311194b3"  This AMI is shared by Trend SEA 
  default = "ami-0791cad5621598606"
}

variable "ami_amzn_devops" {
  # default = "ami-05b3bcf7f311194b3"  This AMI is shared by Trend SEA 
  default = "ami-0ae7781b666d68405"
}

variable "ami_jenkins" {
  # default = "ami-03ee2ca5e7c24bf8f" This AMI is shared by Trend SEA 
  default = "ami-0231160585ec9e425"
}

variable "name" {
  description = "Name tag, e.g stack"
  default     = "vpc"
}

variable "code" {
  #default     = "00"
  default = "monaco"
}

resource "random_id" "r" {
  byte_length = 4
}

variable "admin_ips" {
  type    = list(string)
  default = ["13.251.179.209/32", "203.27.184.158/32", "103.252.203.102/32"]
}



variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = ["10.0.0.0/8"]
}

variable "dsmurl" {
  description = "URL of DSM"
  default     = "52.221.8.233"
}

variable "dsmpolicy" {
  default = "1"
}

variable "copies_unprotected" {
  description = "How many times the victim will be cloned"
  default     = "2"
}

variable "copies_protected" {
  description = "How many times the victim will be cloned"
  default     = "1"
}

variable "r53_variables" {
  default = [""]
}

variable "public_r53_zone_id" {}

variable "public_domain" {}

variable "license" {
  description = "License Key"
  default     = "AP-3HGD-QN92W-Z84PG-4J5KJ-FKWBQ-QPZNC"
}

locals {
  service_name = "forum"
  owner        = "Community Team"
}

variable "eks_instances" {
  default = "0"
}

variable "dsm_count" {
  default = "0"
}

variable "devops_count" {
  default = "1"
}

variable "linux_count" {
  default = "1"
}

variable "victim_count" {
  default = "1"
}

variable "jenkins_count" {
  default = "1"
}

variable "attacker_count" {
  default = "1"
}

variable "apexone_count" {
  default = "0"
}

variable "server_victim" {
  default = "1"
}