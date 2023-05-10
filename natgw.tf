resource "aws_eip" "elastic_ip_natgw" {
  vpc      = true
  tags = {
    Name = "elastic_ip-natgw"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip_natgw.id
  subnet_id     = aws_subnet.public_subnet_1.id


  tags = {
    Name = "nat_gateway"
  }
}

resource "aws_route_table" "Private_Route_Table_NAT" {
  vpc_id = aws_vpc.My_VPC.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "Private_Route_Table_NAT"
  }
}

 resource "aws_route_table_association" "private_subnet_association" {
   subnet_id      = aws_subnet.private_subnet_1.id
   route_table_id = aws_route_table.Private_Route_Table_NAT.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
    subnet_id      = aws_subnet.private_subnet_2.id
    route_table_id = aws_route_table.Private_Route_Table_NAT.id
}