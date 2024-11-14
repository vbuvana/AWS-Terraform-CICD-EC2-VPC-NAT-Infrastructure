variable "vpc_id" {
    type = string
}

variable "subnet_ids" {
   # type = string
}

variable "routes" {
    type = list(object({
        cidr_block = string
        gateway_id = string
    }))
}

variable "tags" {}