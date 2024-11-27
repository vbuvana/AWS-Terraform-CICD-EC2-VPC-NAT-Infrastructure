resource "aws_vpc" "vpc" {
  cidr_block  = var.cidr_block

  tags = {
    Name = "Main VPC"
  }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
      Name = "Internet Gatway"
    }
}
