resource "aws_vpc_endpoint" "endpoint_gwlbe_a" {
  vpc_id            = aws_vpc.vpc_ingress.id
  service_name      = data.aws_vpc_endpoint_service.endpoint_service_gwlb.service_name
  subnet_ids 	    = [aws_subnet.sn_ingress_gwlbe_a.id]
  vpc_endpoint_type = "GatewayLoadBalancer"
  auto_accept	    = true

  tags = {
    Name = "Inbound GWLBe 1"
  }
}

resource "aws_vpc_endpoint" "endpoint_gwlbe_b" {
  vpc_id            = aws_vpc.vpc_ingress.id
  service_name      = data.aws_vpc_endpoint_service.endpoint_service_gwlb.service_name
  subnet_ids 	    = [aws_subnet.sn_ingress_gwlbe_b.id]
  vpc_endpoint_type = "GatewayLoadBalancer"
  auto_accept	    = true

  tags = {
    Name = "Inbound GWLBe 2"
  }
}
