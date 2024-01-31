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

####### VPC #######

data "aws_availability_zones" "az" {
  state = "available"
}


resource "aws_vpc" "myVPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myVPC.id

}

resource "aws_subnet" "publicSubnet1" {
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.az.names[0] # "us-east-1a"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.myVPC.id

}

resource "aws_subnet" "publicSubnet2" {
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.az.names[1] # "us-east-1b"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.myVPC.id

}

resource "aws_subnet" "privateSubnet1" {
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.az.names[0]
  vpc_id            = aws_vpc.myVPC.id

}

resource "aws_subnet" "privateSubnet2" {
  cidr_block        = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.az.names[1]
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

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
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

####### Application Load Balancer #######

resource "aws_lb" "lb" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
  subnets            = [aws_subnet.privateSubnet1.id, aws_subnet.privateSubnet2.id]

}

resource "aws_lb_target_group" "lbtargetGp" {
  name     = "targetgroupalb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myVPC.id
}

resource "aws_lb_listener" "lbListener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lbtargetGp.arn
  }
}


resource "aws_launch_template" "asg_template" {
  name = "asg_template"

  image_id = var.image_id

  instance_type = var.instance_type

  key_name = var.key_name

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_http.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }

  user_data = filebase64("userdata.txt")
}

resource "aws_autoscaling_group" "asg" {
  name                      = "asg"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  vpc_zone_identifier       = [aws_subnet.publicSubnet1.id, aws_subnet.publicSubnet2.id]
  desired_capacity          = 2
  max_size                  = 3
  min_size                  = 1
  target_group_arns         = [aws_lb_target_group.targetGp.arn]
  launch_template {
    id      = aws_launch_template.asg_template.id
    version = "$Latest"
  }
}