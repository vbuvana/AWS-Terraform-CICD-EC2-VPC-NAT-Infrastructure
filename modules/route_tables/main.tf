resource "aws_route_table" "route_table" {
vpc_id = var.vpc_id
tags = var.tags

dynamic "route" {
  for_each = var.routes
  content {
    cidr_block = route.value.cidr_block
    gateway_id = route.value.gateway_id

  }
}

}

resource "aws_route_table_association" "rt_association" {
  count = length(var.subnet_ids)
  subnet_id      = var.subnet_ids[count.index]
  route_table_id = aws_route_table.route_table.id
}
