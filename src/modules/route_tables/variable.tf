variable "vpc_id" {
    description ="ID of the VPC"
}

variable "subnet_ids" {
   description = "ID of the subnet"
}

variable "routes" {
    type = list(object({
        cidr_block = string
        gateway_id = string
    }))
}

variable "tags" {
    description = "Route Table"
}