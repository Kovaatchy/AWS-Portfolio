terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

####### VPC #######

resource "aws_vpc" "myVPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myVPC.id

}

resource "aws_subnet" "publicSubnet1" {
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.myVPC.id

}

resource "aws_subnet" "publicSubnet2" {
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.myVPC.id

}

resource "aws_subnet" "privateSubnet1" {
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  vpc_id            = aws_vpc.myVPC.id

}

resource "aws_subnet" "privateSubnet2" {
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  vpc_id            = aws_vpc.myVPC.id

}

resource "aws_route_table" "myInternetRouteTable" {
  vpc_id = aws_vpc.myVPC.id
}

resource "aws_route" "myInternetRoute" {
  route_table_id         = aws_route_table.myInternetRouteTable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.myigw.id
  depends_on             = [aws_route_table.myInternetRouteTable]
}

resource "aws_route_table_association" "myRouteTablesubnet1_attach" {
  subnet_id      = aws_subnet.publicSubnet1.id
  route_table_id = aws_route_table.myInternetRouteTable.id
}

resource "aws_route_table_association" "myRouteTablesubnet2_attach" {
  subnet_id      = aws_subnet.publicSubnet2.id
  route_table_id = aws_route_table.myInternetRouteTable.id
}

####### Security Group #######

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "allow_mysql" {
  depends_on  = [aws_security_group.allow_ssh]
  name        = "allow_mysql"
  description = "Allow MYSQL inbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description     = "MYSQL from VPC"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.allow_ssh.id]
  }

}

####### RDS #######

resource "aws_db_subnet_group" "db_subnetGroup_rds" {
  name       = "db_subnetgroup_rds"
  subnet_ids = [aws_subnet.privateSubnet1.id, aws_subnet.privateSubnet2.id]

}

resource "aws_db_instance" "mydb" {
  allocated_storage    = 10
  db_name              = "mydb"
  db_subnet_group_name = aws_db_subnet_group.db_subnetGroup_rds.name
  engine               = "mariadb"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "admin1234"
  vpc_security_group_ids = [aws_security_group.allow_mysql.id]
  skip_final_snapshot  = true
}

