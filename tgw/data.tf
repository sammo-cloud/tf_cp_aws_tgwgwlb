data "aws_vpc" "vpc_egress" {
  tags = {
    Name = "${var.project_name}-GWLB-VPCStack-*"
  }
}

data "aws_subnet" "sn_egress_gwlbe_a" {
  vpc_id = data.aws_vpc.vpc_egress.id
  tags = {
    Name = "GWLBe subnet 1"
  }
}

data "aws_subnet" "sn_egress_gwlbe_b" {
  vpc_id = data.aws_vpc.vpc_egress.id
  tags =  {
    Name = "GWLBe subnet 2"
  }
}

data "aws_subnet" "sn_egress_natgw_a" {
  vpc_id = data.aws_vpc.vpc_egress.id
  tags =  {
    Name = "NAT subnet 1"
  }
}

data "aws_subnet" "sn_egress_natgw_b" {
  vpc_id = data.aws_vpc.vpc_egress.id
  tags =  {
    Name = "NAT subnet 2"
  }
}

data "aws_subnet" "sn_egress_tgw_a" {
  vpc_id = data.aws_vpc.vpc_egress.id
  tags =  {
    Name = "TGW subnet 1"
  }
}

data "aws_subnet" "sn_egress_tgw_b" {
  vpc_id = data.aws_vpc.vpc_egress.id
  tags =  {
    Name = "TGW subnet 2"
  }
}

data "aws_route_table" "rt_egress_gwlbe_a" {
  subnet_id = data.aws_subnet.sn_egress_gwlbe_a.id
}

data "aws_route_table" "rt_egress_gwlbe_b" {
  subnet_id = data.aws_subnet.sn_egress_gwlbe_b.id
}

data "aws_route_table" "rt_egress_natgw_a" {
  subnet_id = data.aws_subnet.sn_egress_natgw_a.id
}

data "aws_route_table" "rt_egress_natgw_b" {
  subnet_id = data.aws_subnet.sn_egress_natgw_b.id
}

data "aws_route_table" "rt_egress_tgw_a" {
  subnet_id = data.aws_subnet.sn_egress_tgw_a.id
}

data "aws_route_table" "rt_egress_tgw_b" {
  subnet_id = data.aws_subnet.sn_egress_tgw_b.id
}

data "aws_vpc_endpoint_service" "endpoint_service_gwlb" {
  service_type = "GatewayLoadBalancer"
}

data "aws_route" "r_egress_tgw_a_tointernet" {
  route_table_id = data.aws_route_table.rt_egress_tgw_a.id
  destination_cidr_block = "0.0.0.0/0"
}

data "aws_route" "r_egress_tgw_b_tointernet" {
  route_table_id = data.aws_route_table.rt_egress_tgw_b.id
  destination_cidr_block = "0.0.0.0/0"
}
