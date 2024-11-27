provider "aws" {
  region = var.region
}

# Fetch the available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.vpc_cidr_block
}

#Public Subnet

module "public_subnet" {
  source = "./modules/subnet"
  vpc_id            = module.vpc.vpc_id
  cidr_block        = var.public_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}


module "private_subnet" {
  source = "./modules/subnet"
  vpc_id            = module.vpc.vpc_id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
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
  vpc_id = module.vpc.vpc_id
  subnet_ids = [module.public_subnet.subnet_id]
  routes = [
    {
        cidr_block = "0.0.0.0/0"
        gateway_id = module.vpc.internet_gateway_id#attach IGW for public routing
    }
  ]
  
  tags = {
    Name = "Public Route Table"
  }

}

#private route table

module "private_route_table" {
  source = "./modules/route_tables"
  vpc_id = module.vpc.vpc_id
  subnet_ids = [module.private_subnet.subnet_id]
  routes = [{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id #attach NAT for private routing

  }]
  tags = {
    Name = "Private Route Table"
  }
}

# Security Groups - Public + Private
module "security_group_public" {
  source  = "./modules/security_group"
  sg_type = "public"
  vpc_id  = module.vpc.vpc_id
}

module "security_group_private" {
  source  = "./modules/security_group"
  sg_type = "private"
  vpc_id = module.vpc.vpc_id
}

#EC2 instance in public subnet
module "ec2_public" {
  source = "./modules/ec2"
  subnet_id = module.public_subnet.subnet_id
  ami_id   = var.ec2_ami_id
  instance_type = var.ec2_instance_type
  security_group_ids = [module.security_group_public.sg_id]
  key_name          = "${var.key_name_prefix}public"
  instance_name     = var.instance_name["public"]
  associate_public_ip_address = true

}

#EC2 instance in private subnet
module "ec2_private" {
  source = "./modules/ec2"
  subnet_id = module.private_subnet.subnet_id
  ami_id = var.ec2_ami_id
  instance_type = var.ec2_instance_type
  security_group_ids = [module.security_group_private.sg_id]
  key_name          = "${var.key_name_prefix}private"
  instance_name     = var.instance_name["private"]
  associate_public_ip_address = false
}