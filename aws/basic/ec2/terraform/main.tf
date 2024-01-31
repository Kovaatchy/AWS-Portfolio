terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

variable "vpc_id" {
  default = "vpc-094d10f69c68d1693"
}

data "aws_vpc" "main" {
  id = var.vpc_id
}

resource "aws_security_group" "ec2sg" {
  name        = "ec2sg"
  description = "ec2sg"
  vpc_id      = data.aws_vpc.main.id
  tags = {
    Name = "ec2sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.ec2sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.ec2sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}


resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.ec2sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_instance" "web" {
  ami                    = "ami-079db87dc4c10ac91"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2sg.id]
  key_name               = "ec2_key"
  #  subnet_id= ""
  user_data = file("userdata.sh")
}

