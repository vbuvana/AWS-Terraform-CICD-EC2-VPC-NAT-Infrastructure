/*terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.8.0"
    }
  }
}*/

provider "aws" {
  region = "us-west-2"
}
# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Main VPC"
  }
}

module "public_subnet" {
  source = "./modules/subnet"
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
}


module "private_subnet" {
  source = "./modules/subnet"
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = false
}

#Internergateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
      Name = "Internet Gatway"
    }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  tags = {
    Name = "NAT Gateway EIP"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = module.public_subnet.subnet_id  # Attach NAT Gateway to Public Subnet-1

  tags = {
    Name = "NAT Gateway"
  }
}
#public route table

module "public_route_table" {
  source = "./modules/route_tables"
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [module.public_subnet.subnet_id]
  routes = [
    {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id #attach IGW for public routing
    }
  ]
  
  tags = {
    Name = "Public Route Table"
  }

}

#private route table

module "private_route_table" {
  source = "./modules/route_tables"
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [module.private_subnet.subnet_id]
  routes = [{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id #attach NAT for private routing

  }]
  tags = {
    Name = "Private Route Table"
  }
}

#security group
module "security_group" {
  source = "./modules/security_group"
  vpc_id = aws_vpc.vpc.id
  ingress_cidr = "0.0.0.0/0"
  tags = {
    Name = "Security Group"
  }
}

#EC2 instance in public subnet
module "ec2_public" {
  source = "./modules/ec2"
  subnet_id = module.public_subnet.subnet_id
  ami = "ami-04dd23e62ed049936"
  instance_type = "t2.micro"
  security_group_ids = [module.security_group.security_group_id]
  tags = {
    Name = "Public EC2 Instance"
  }
}

#EC2 instance in private subnet
module "ec2_private" {
  source = "./modules/ec2"
  subnet_id = module.private_subnet.subnet_id
  ami = "ami-04dd23e62ed049936"
  instance_type = "t2.micro"
  security_group_ids = [module.security_group.security_group_id]
  tags = {
    Name = "Private EC2 Instance"
  }
}