################################################
#### Transit Gateway
################################################

data "aws_subnet" "sn_gwlb_tgwha_a" {
  filter {
    name   = "tag:Name"
    values = ["TGW subnet 1"]
  }
}

data "aws_subnet" "sn_gwlb_tgwha_b" {
 filter {
    name   = "tag:Name"
    values = ["TGW subnet 2"]
  }
}

resource "aws_ec2_transit_gateway" "tgw_gwlb" {
  description = "${var.project_name} GWLB TGW"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgwatt_gwlb" {
  subnet_ids         = [data.aws_subnet.sn_gwlb_tgwha_a.id,data.aws_subnet.sn_gwlb_tgwha_b.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw_gwlb.id
  vpc_id             = data.aws_subnet.sn_gwlb_tgwha_a.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgwatt_spoke" {
  subnet_ids         = [aws_subnet.sn_spoke_tgwha_a.id,aws_subnet.sn_spoke_tgwha_b.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw_gwlb.id
  vpc_id             = aws_vpc.vpc_spoke.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgwatt_ingress" {
  subnet_ids         = [aws_subnet.sn_ingress_tgwha_a.id,aws_subnet.sn_ingress_tgwha_b.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw_gwlb.id
  vpc_id             = aws_vpc.vpc_ingress.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

resource "aws_ec2_transit_gateway_route_table" "tgwrt_gwlb" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw_gwlb.id

  tags = {
      "Name" = "${var.project_name} GWLB Associated Route Table"
  }
}

resource "aws_ec2_transit_gateway_route_table" "tgwrt_ingress" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw_gwlb.id

  tags = {
      "Name" = "${var.project_name} Ingress Associated Route Table"
  }
}

resource "aws_ec2_transit_gateway_route_table" "tgwrt_spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw_gwlb.id

  tags = {
      "Name" = "${var.project_name} Spoke Associated Route Table"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "tgwrta_gwlb" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgwatt_gwlb.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_gwlb.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgwrta_ingress" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgwatt_ingress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_ingress.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgwrta_spoke" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgwatt_spoke.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_spoke.id
}

resource "aws_ec2_transit_gateway_route" "tgwr_spoketointernet" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgwatt_gwlb.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_spoke.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgwrtp_gwlbtospoke" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgwatt_spoke.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_gwlb.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgwrtp_spoketoingress" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgwatt_ingress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_spoke.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgwrtp_ingresstospoke" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgwatt_spoke.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_ingress.id
}

################################################
#### Spoke VPC
################################################
resource "aws_vpc" "vpc_spoke" {
    cidr_block           = var.vpc_spoke_cidr
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"

    tags = {
        "Name" = "${var.project_name} Spoke VPC"
    }
}

resource "aws_subnet" "sn_spoke_public_a" {
    vpc_id                  = aws_vpc.vpc_spoke.id
    cidr_block              = cidrsubnet(var.vpc_spoke_cidr, 8, 1)
    availability_zone       = "${var.aws_region}a"
    map_public_ip_on_launch = true

    tags = {
        "Name" = "${var.project_name} Spoke Public subnet 1"
        "Network" = "Public"
    }
}

resource "aws_subnet" "sn_spoke_private_a" {
    vpc_id                  = aws_vpc.vpc_spoke.id
    cidr_block              = cidrsubnet(var.vpc_spoke_cidr, 8, 11)
    availability_zone       = "${var.aws_region}a"
    map_public_ip_on_launch = false

    tags = {
        "Network" = "Private"
        "Name" = "${var.project_name} Spoke Private subnet 1"
    }
}

resource "aws_subnet" "sn_spoke_tgwha_a" {
    vpc_id                  = aws_vpc.vpc_spoke.id
    cidr_block              = cidrsubnet(var.vpc_spoke_cidr, 8, 201)
    availability_zone       = "${var.aws_region}a"
    map_public_ip_on_launch = false

    tags = {
        "Network" = "Private"
        "Name" = "${var.project_name} Spoke TGW HA subnet 1"
    }
}

resource "aws_subnet" "sn_spoke_tgwha_b" {
    vpc_id                  = aws_vpc.vpc_spoke.id
    cidr_block              = cidrsubnet(var.vpc_spoke_cidr, 8, 202)
    availability_zone       = "${var.aws_region}b"
    map_public_ip_on_launch = false

    tags = {
        "Name" = "${var.project_name} Spoke TGW HA subnet 2"
        "Network" = "Private"
    }
}

resource "aws_subnet" "sn_spoke_public_b" {
    vpc_id                  = aws_vpc.vpc_spoke.id
    cidr_block              = cidrsubnet(var.vpc_spoke_cidr, 8, 2)
    availability_zone       = "${var.aws_region}b"
    map_public_ip_on_launch = true

    tags = {
        "Network" = "Public"
        "Name" = "${var.project_name} Spoke Public subnet 2"
    }
}

resource "aws_subnet" "sn_spoke_private_b" {
    vpc_id                  = aws_vpc.vpc_spoke.id
    cidr_block              = cidrsubnet(var.vpc_spoke_cidr, 8, 12)
    availability_zone       = "${var.aws_region}b"
    map_public_ip_on_launch = false

    tags = {
        "Network" = "Private"
        "Name" = "${var.project_name} Spoke Private subnet 2"
    }
}

resource "aws_route_table" "rt_spoke_public" {
    vpc_id     = aws_vpc.vpc_spoke.id

    route {
        cidr_block = "0.0.0.0/0"
        transit_gateway_id = aws_ec2_transit_gateway.tgw_gwlb.id
    }

    tags = {
        "Name" = "${var.project_name} Spoke Public Subnets"
        "Network" = "Public"
    }
}

resource "aws_route_table" "rt_spoke_private" {
    vpc_id     = aws_vpc.vpc_spoke.id

    tags = {
        "Name" = "${var.project_name} Spoke Private Subnets"
    }
}

resource "aws_route_table_association" "rta_spoke_public_a" {
    route_table_id = aws_route_table.rt_spoke_public.id
    subnet_id = aws_subnet.sn_spoke_public_a.id
}

resource "aws_route_table_association" "rta_spoke_public_b" {
    route_table_id = aws_route_table.rt_spoke_public.id
    subnet_id = aws_subnet.sn_spoke_public_b.id
}

################################################
#### Ingress VPC
################################################
resource "aws_vpc" "vpc_ingress" {
    cidr_block           = var.vpc_ingress_cidr
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"

    tags = {
        "Name" = "${var.project_name} Ingress VPC"
    }
}

resource "aws_subnet" "sn_ingress_gwlbe_a" {
    vpc_id                  = aws_vpc.vpc_ingress.id
    cidr_block              = cidrsubnet(var.vpc_ingress_cidr, 8, 1)
    availability_zone       = "${var.aws_region}a"
    map_public_ip_on_launch = true

    tags = {
        "Name" = "${var.project_name} Ingress GWLBe subnet 1"
        "Network" = "Public"
    }
}

resource "aws_subnet" "sn_ingress_alb_a" {
    vpc_id                  = aws_vpc.vpc_ingress.id
    cidr_block              = cidrsubnet(var.vpc_ingress_cidr, 8, 11)
    availability_zone       = "${var.aws_region}a"
    map_public_ip_on_launch = false

    tags = {
        "Network" = "Private"
        "Name" = "${var.project_name} Ingress ALB subnet 1"
    }
}

resource "aws_subnet" "sn_ingress_tgwha_a" {
    vpc_id                  = aws_vpc.vpc_ingress.id
    cidr_block              = cidrsubnet(var.vpc_ingress_cidr, 8, 201)
    availability_zone       = "${var.aws_region}a"
    map_public_ip_on_launch = false

    tags = {
        "Network" = "Private"
        "Name" = "${var.project_name} Ingress TGW subnet 1"
    }
}

resource "aws_subnet" "sn_ingress_tgwha_b" {
    vpc_id                  = aws_vpc.vpc_ingress.id
    cidr_block              = cidrsubnet(var.vpc_ingress_cidr, 8, 202)
    availability_zone       = "${var.aws_region}b"
    map_public_ip_on_launch = false

    tags = {
        "Name" = "${var.project_name} Ingress TGW subnet 2"
        "Network" = "Private"
    }
}

resource "aws_subnet" "sn_ingress_gwlbe_b" {
    vpc_id                  = aws_vpc.vpc_ingress.id
    cidr_block              = cidrsubnet(var.vpc_ingress_cidr, 8, 2)
    availability_zone       = "${var.aws_region}b"
    map_public_ip_on_launch = true

    tags = {
        "Network" = "Public"
        "Name" = "${var.project_name} Ingress GWLBe subnet 2"
    }
}

resource "aws_subnet" "sn_ingress_alb_b" {
    vpc_id                  = aws_vpc.vpc_ingress.id
    cidr_block              = cidrsubnet(var.vpc_ingress_cidr, 8, 12)
    availability_zone       = "${var.aws_region}b"
    map_public_ip_on_launch = false

    tags = {
        "Network" = "Private"
        "Name" = "${var.project_name} Ingress ALB subnet 2"
    }
}

resource "aws_internet_gateway" "igw_ingress" {
    vpc_id     = aws_vpc.vpc_ingress.id

    tags = {
        "Network" = "Public"
        "Name" = "${var.project_name} Ingress IGW"
    }
}

resource "aws_route_table" "rt_ingress_igw" {
    vpc_id     = aws_vpc.vpc_ingress.id

    route {
	cidr_block = aws_subnet.sn_ingress_alb_a.cidr_block
	vpc_endpoint_id = aws_vpc_endpoint.endpoint_gwlbe_a.id
    }

    route {
	cidr_block = aws_subnet.sn_ingress_alb_b.cidr_block
	vpc_endpoint_id = aws_vpc_endpoint.endpoint_gwlbe_b.id
    }

    tags = {
        "Name" = "${var.project_name} Ingress IGW"
        "Network" = "Public"
    }
}

resource "aws_route_table" "rt_ingress_alb_a" {
    vpc_id     = aws_vpc.vpc_ingress.id

    route {
        cidr_block = "0.0.0.0/0"
	vpc_endpoint_id = aws_vpc_endpoint.endpoint_gwlbe_a.id
    }

    route {
    	cidr_block = aws_vpc.vpc_spoke.cidr_block
    	transit_gateway_id = aws_ec2_transit_gateway.tgw_gwlb.id
    }

    tags = {
        "Name" = "${var.project_name} Ingress ALB Subnets 1"
        "Network" = "Public"
    }
}

resource "aws_route_table" "rt_ingress_alb_b" {
    vpc_id     = aws_vpc.vpc_ingress.id

    route {
        cidr_block = "0.0.0.0/0"
	vpc_endpoint_id = aws_vpc_endpoint.endpoint_gwlbe_b.id
    }

    route {
    	cidr_block = aws_vpc.vpc_spoke.cidr_block
    	transit_gateway_id = aws_ec2_transit_gateway.tgw_gwlb.id
    }

    tags = {
        "Name" = "${var.project_name} Ingress ALB Subnets 2"
        "Network" = "Public"
    }
}

resource "aws_route_table" "rt_ingress_gwlbe_a" {
    vpc_id     = aws_vpc.vpc_ingress.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_ingress.id
    }

    tags = {
        "Name" = "${var.project_name} Ingress GWLBe Subnets 1"
        "Network" = "Public"
    }
}

resource "aws_route_table" "rt_ingress_gwlbe_b" {
    vpc_id     = aws_vpc.vpc_ingress.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_ingress.id
    }

    tags = {
        "Name" = "${var.project_name} Ingress GWLBe Subnets 2"
        "Network" = "Public"
    }
}

resource "aws_route_table" "rt_ingress_tgwha_a" {
    vpc_id     = aws_vpc.vpc_ingress.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_ingress.id
    }

    tags = {
        "Name" = "${var.project_name} Ingress TGW Subnets 1"
        "Network" = "Public"
    }
}

resource "aws_route_table" "rt_ingress_tgwha_b" {
    vpc_id     = aws_vpc.vpc_ingress.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_ingress.id
    }

    tags = {
        "Name" = "${var.project_name} Ingress TGW Subnets 2"
        "Network" = "Public"
    }
}

resource "aws_route_table" "rt_ingress_private" {
    vpc_id     = aws_vpc.vpc_ingress.id

    tags = {
        "Name" = "${var.project_name} Ingress Private Subnets"
    }
}


resource "aws_route_table_association" "rta_ingress_igw" {
    route_table_id = aws_route_table.rt_ingress_igw.id
    gateway_id = aws_internet_gateway.igw_ingress.id
}

resource "aws_route_table_association" "rta_ingress_alb_a" {
    route_table_id = aws_route_table.rt_ingress_alb_a.id
    subnet_id = aws_subnet.sn_ingress_alb_a.id
}

resource "aws_route_table_association" "rta_ingress_alb_b" {
    route_table_id = aws_route_table.rt_ingress_alb_b.id
    subnet_id = aws_subnet.sn_ingress_alb_b.id
}

resource "aws_route_table_association" "rta_ingress_gwlbe_a" {
    route_table_id = aws_route_table.rt_ingress_gwlbe_a.id
    subnet_id = aws_subnet.sn_ingress_gwlbe_a.id
}

resource "aws_route_table_association" "rta_ingress_gwlbe_b" {
    route_table_id = aws_route_table.rt_ingress_gwlbe_b.id
    subnet_id = aws_subnet.sn_ingress_gwlbe_b.id
}

resource "aws_route_table_association" "rta_ingress_tgwha_a" {
    route_table_id = aws_route_table.rt_ingress_tgwha_a.id
    subnet_id = aws_subnet.sn_ingress_tgwha_a.id
}

resource "aws_route_table_association" "rta_ingress_tgwha_b" {
    route_table_id = aws_route_table.rt_ingress_tgwha_b.id
    subnet_id = aws_subnet.sn_ingress_tgwha_b.id
}

################################################
#### Ingress VPC
################################################

resource "aws_route" "r_gwlbe_a_tospoke" {
    route_table_id            = data.aws_route_table.rt_egress_gwlbe_a.id
    destination_cidr_block    = var.vpc_spoke_cidr
    transit_gateway_id = aws_ec2_transit_gateway.tgw_gwlb.id
}

resource "aws_route" "r_gwlbe_b_tospoke" {
    route_table_id            = data.aws_route_table.rt_egress_gwlbe_b.id
    destination_cidr_block    = var.vpc_spoke_cidr
    transit_gateway_id = aws_ec2_transit_gateway.tgw_gwlb.id
}

resource "aws_route" "r_natgw_a_tospoke" {
    route_table_id            = data.aws_route_table.rt_egress_natgw_a.id
    destination_cidr_block    = var.vpc_spoke_cidr
    vpc_endpoint_id = data.aws_route.r_egress_tgw_a_tointernet.gateway_id
}

resource "aws_route" "r_natgw_b_tospoke" {
    route_table_id            = data.aws_route_table.rt_egress_natgw_b.id
    destination_cidr_block    = var.vpc_spoke_cidr
    vpc_endpoint_id = data.aws_route.r_egress_tgw_b_tointernet.gateway_id
}
