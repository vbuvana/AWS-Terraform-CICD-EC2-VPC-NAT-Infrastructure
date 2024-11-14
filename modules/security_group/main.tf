resource "aws_security_group" "sg" {
    vpc_id = var.vpc_id
    tags = var.tags

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.ingress_cidr]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [var.ingress_cidr]
    }

}