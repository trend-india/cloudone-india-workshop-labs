#Set the region and use AWS

#Get AZs in the region
data "aws_availability_zones" "azs" {
    state = "available"
}

####Attacker VPC####
#Create the VPC and Security Group
resource "aws_vpc" "attacker_vpc" {
  cidr_block = var.attacker_vpc.cidr

  tags = {
    Name        = format("%s - %s", var.unique_id, var.attacker_vpc.name)
    Description = format("%s - %s", var.unique_id, var.attacker_vpc.desc)
  }
}
resource "aws_security_group" "attacker_sg" {
  vpc_id      = aws_vpc.attacker_vpc.id
  name        = format("%s - %s - %s", var.unique_id, var.attacker_vpc.name, "Attacker - SG")
  description = format("%s - %s - %s", var.unique_id, var.attacker_vpc.name, "SG")

  #allow SSH connections from any IP.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #allow connect to the attack website.
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #allow any traffic to egress to the Internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Add and IGW
resource "aws_internet_gateway" "attacker_igw" {
  vpc_id     = aws_vpc.attacker_vpc.id
  tags = {
    Name = format("%s - %s - %s", var.unique_id, var.attacker_vpc.name, "IGW")
  }
}

#Create public subnet for the Attacker VPC
resource "aws_subnet" "attacker_sub1" {
  vpc_id                  = aws_vpc.attacker_vpc.id
  cidr_block              = var.attacker_vpc.pub_sub1_cidr
  map_public_ip_on_launch = "true"

  tags = {
    Name = format("%s - %s", var.unique_id, var.attacker_vpc.pub_sub1_name)
  }
}
resource "aws_route_table" "attacker_sub1_rtb" {
  vpc_id = aws_vpc.attacker_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id     = aws_internet_gateway.attacker_igw.id
  }
  tags = {
    Name = format("%s - %s - %s", var.unique_id, var.attacker_vpc.pub_sub1_name, "RTB")
  }
}
resource "aws_route_table_association" "attacker_sub1_rtb_ass" {
  subnet_id      = aws_subnet.attacker_sub1.id
  route_table_id = aws_route_table.attacker_sub1_rtb.id
}
resource "aws_route" "attacker_sub1_default_route" {
  route_table_id            = aws_route_table.attacker_sub1_rtb.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.attacker_igw.id
}

####Internet facing VPC####
#Create the Internet facing VPC
resource "aws_vpc" "inet_vpc" {
  cidr_block = var.inet_vpc.cidr

  tags = {
    Name        = format("%s - %s", var.unique_id, var.inet_vpc.name)
    Description = format("%s - %s", var.unique_id, var.inet_vpc.desc)
  }
}
resource "aws_security_group" "inet_pub_sg" {
  vpc_id      = aws_vpc.inet_vpc.id
  name        = format("%s - %s - %s", var.unique_id, var.inet_vpc.name, "Public Subnet - SG")
  description = format("%s - %s - %s", var.unique_id, var.inet_vpc.name, "SG")

  #allow SSH connections from any IP.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #allow any traffic to egress to the Internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "inet_ips_sg" {
  vpc_id      = aws_vpc.inet_vpc.id
  name        = format("%s - %s - %s", var.unique_id, var.inet_vpc.name, "IPS - SG")
  description = format("%s - %s - %s", var.unique_id, var.inet_vpc.name, "IPS - SG")

  #allow all traffic from anywhere
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #allow any traffic to egress to the Internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "inet_prot_sg" {
  vpc_id      = aws_vpc.inet_vpc.id
  name        = format("%s - %s - %s", var.unique_id, var.inet_vpc.name, "Protected Subnet - SG")
  description = format("%s - %s - %s", var.unique_id, var.inet_vpc.name, "SG")

  #allow SSH connections from any IP.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 8516
    to_port     = 8516
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.struts_port
    to_port     = var.struts_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.dvwa_port
    to_port     = var.dvwa_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #allow any traffic to egress to the Internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#Add an IGW
resource "aws_internet_gateway" "igw" {
  vpc_id     = aws_vpc.inet_vpc.id
  tags = {
    Name = format("%s - %s - %s", var.unique_id, var.inet_vpc.name, "IGW")
  }
}

#Create Public Subnets for Internet VPC
resource "aws_subnet" "inet_pub_sub1" {
  vpc_id                  = aws_vpc.inet_vpc.id
  cidr_block              = var.inet_vpc.pub_sub1_cidr
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.azs.names[0]
  tags = {
    Name = format("%s - %s", var.unique_id, var.inet_vpc.pub_sub1_name)
  }
}



#Create an NGW in each AZ
resource "aws_eip" "ngw1_eip" {
  vpc = true
}
resource "aws_nat_gateway" "ngw1" {
  allocation_id = aws_eip.ngw1_eip.id
  subnet_id     = aws_subnet.inet_pub_sub1.id
  tags = {
    Name = format("%s - %s", var.unique_id, "NGW1")
  }
}



#Create Protected Subnets for Internet VPC
resource "aws_subnet" "inet_prot_sub1" {
    vpc_id          = aws_vpc.inet_vpc.id
    cidr_block      = var.inet_vpc.prot_sub1_cidr
    availability_zone = aws_subnet.inet_pub_sub1.availability_zone

    tags = {
        Name = format("%s - %s", var.unique_id, var.inet_vpc.prot_sub1_name)
    }
}
resource "aws_route_table" "inet_prot_sub1_rtb" {
  vpc_id     = aws_vpc.inet_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id     = aws_internet_gateway.igw.id
  }
  tags = {
    Name = format("%s - %s - %s", var.unique_id, var.inet_vpc.prot_sub1_name, "RTB")
  }
}
resource "aws_route_table_association" "inet_prot_sub1_rtb_ass" {
  subnet_id      = aws_subnet.inet_prot_sub1.id
  route_table_id = aws_route_table.inet_prot_sub1_rtb.id
}




resource "aws_route_table" "pub_sub1_rtb" {
  vpc_id = aws_vpc.inet_vpc.id

  tags = {
    Name = format("%s - %s - %s", var.unique_id, var.inet_vpc.pub_sub1_name, "RTB")
  }
}
resource "aws_route_table_association" "pub_sub1_rtb_ass" {
  subnet_id      = aws_subnet.inet_pub_sub1.id
  route_table_id = aws_route_table.pub_sub1_rtb.id
}
resource "aws_route" "inet_pub_sub1_default_route" {
  route_table_id            = aws_route_table.pub_sub1_rtb.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.igw.id
}






####instances####
#Ubuntu AMI
data "aws_ami" "ubuntu_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
#attacker instance
resource "aws_eip" "attacker_eip" {
  vpc = true
}
resource "aws_eip_association" "attacker_eip_ass" {
  allocation_id = aws_eip.attacker_eip.id
  network_interface_id = aws_network_interface.attacker_eni.id
}
resource "aws_network_interface" "attacker_eni" {
  subnet_id        = aws_subnet.attacker_sub1.id
  security_groups = [aws_security_group.attacker_sg.id]
}
resource "aws_instance" "attacker_host" {
  depends_on             = [aws_instance.work_host1]
  ami                    = data.aws_ami.ubuntu_ami.id
  instance_type          = var.types.bastion
  key_name               = var.key_pair
  
  network_interface {
    network_interface_id = aws_network_interface.attacker_eni.id
    device_index         = 0
  }

  provisioner "remote-exec" {
    inline = [<<-EOF
      sudo apt update
      sudo apt-get update
      sudo apt install python -y
      sudo apt install python3-venv -y
      sudo apt install python3-pip -y
      git clone https://github.com/AshrafBarakat93/cnp_demo_flask.git
      cd cnp_demo_flask
      pip3 install -r requirements.txt
      export VICTIM_HOST=${aws_eip.work1_eip.public_ip}
      echo ${aws_eip.work1_eip.public_ip} > VICTIM_HOST.txt
      export STRUTS_PORT=${var.struts_port}
      echo ${var.struts_port} > STRUTS_PORT.txt
      #./init.sh
      sudo tee -a /lib/systemd/system/flask_web.service > /dev/null <<EOT
[Unit]
Description=Demo Attack Site
After=network.target
[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/cnp_demo_flask
ExecStart=/usr/bin/python3 /home/ubuntu/cnp_demo_flask/app.py
Restart=always
[Install]
WantedBy=multi-user.target
EOT
      sudo systemctl daemon-reload
      sudo systemctl enable flask_web.service
      sudo systemctl start flask_web.service
      EOF
    ]

  connection {
      type = "ssh"
      user = "ubuntu"
      timeout = "6m"
      host = aws_instance.attacker_host.public_ip
      private_key = file("${path.module}/cloudone-india-john.pem") 
      agent = false
    }
  }
  tags = {
    Name = format("%s - %s", var.unique_id, "Attacker instance")
    Description = "Attacker instance"
  }
}

#Workload Hosts
resource "aws_eip" "work1_eip" {
  vpc = true
}
resource "aws_eip_association" "work1_eip_ass" {
  allocation_id = aws_eip.work1_eip.id
  network_interface_id = aws_network_interface.work1_eni.id
}
resource "aws_network_interface" "work1_eni" {
  subnet_id        = aws_subnet.inet_prot_sub1.id
  security_groups  = [aws_security_group.inet_prot_sg.id]
}
resource "aws_instance" "work_host1" {
  ami = data.aws_ami.ubuntu_ami.id
  instance_type = var.types.work
  key_name = var.key_pair

  network_interface {
    network_interface_id = aws_network_interface.work1_eni.id
    device_index         = 0
  }

  user_data = <<EOF
  #cloud-config
  repo_update: true
  repo_upgrade: all

  packages:

  runcmd:
    - curl -fsSL https://get.docker.com -o get-docker.sh; sh get-docker.sh
    - [ sh, -c, "sudo docker run -d -p ${var.struts_port}:${var.struts_port} --name lab-apache-struts jrrdev/cve-2017-5638" ]
    - [ sh, -c, "sudo docker run -d -p ${var.dvwa_port}:${var.dvwa_port} --name lab-dvwa vulnerables/web-dvwa" ]
    - systemctl status nginx
 EOF
  tags = {
    Name        = format("%s - %s", var.unique_id, "Workload instance 1")
    Description = "Workload instance 1"
  }
}


#bastion Host
resource "aws_eip" "bastion_eip" {
  vpc = true
}
resource "aws_eip_association" "bastion_eip_ass" {
  allocation_id = aws_eip.bastion_eip.id
  network_interface_id = aws_network_interface.bastion_eni.id
}
resource "aws_network_interface" "bastion_eni" {
  subnet_id        = aws_subnet.inet_prot_sub1.id
  security_groups  = [aws_security_group.inet_prot_sg.id]
}
resource "aws_instance" "bastion" {
  depends_on  = [aws_instance.Splunk]
  ami = "ami-024f1051ad385755a"
  instance_type = var.types.bastion
  key_name = var.key_pair
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  network_interface {
    network_interface_id = aws_network_interface.bastion_eni.id
    device_index         = 0
  }


user_data              = templatefile("${path.module}/bastion.ps1",{code = "${var.unique_id}", Splunk_URL = "${aws_instance.Splunk.public_ip}", Splunk_Pass = "${aws_instance.Splunk.id}", attacker_website = "${aws_eip.attacker_eip.public_ip}", workload_ip = "${aws_eip.work1_eip.public_ip}"})

  tags = {
    Name        = format("%s - %s", var.unique_id, "bastion-NS")
    Description = "bastion instance "
  }
}

resource "aws_route53_record" "pub-ns" {
  zone_id = var.public_r53_zone_id
  name    = var.unique_id
  type    = "A"
  ttl     = "30"

  records = [
    aws_eip.bastion_eip.public_ip,
  ]
}


#Splunk


resource "aws_instance" "Splunk" {
  ami = "ami-07f60d8d1e8ae7835"
  instance_type = var.types.work
  key_name = var.key_pair
  associate_public_ip_address = true
  subnet_id        = aws_subnet.inet_prot_sub1.id
  security_groups  = [aws_security_group.inet_prot_sg.id]

  tags = {
    Name        = format("%s - %s", var.unique_id, "Splunk-NS")
    Description = "Splunk instance"
  }
}





####OUTPUTS####
output "attacker_public_ip" {
  value = aws_eip.attacker_eip.public_ip
}
output "attacker_website" {
  value = format("http://%s:5000", aws_eip.attacker_eip.public_ip)
}
output "workload1_public_ip" {
  value = aws_eip.work1_eip.public_ip
}
output "workload1_vulnerable_webite" {
  value = format("http://%s", aws_eip.work1_eip.public_ip)
}
output "workload1_vuln_website_login_info" {
  value = format("%s/%s", "admin", "password")
}

