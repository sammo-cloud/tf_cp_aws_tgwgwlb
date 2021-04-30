resource "aws_security_group" "sg_permissive" {
  name        = "Permissive"
  description = "Permissive"
  vpc_id      = aws_vpc.vpc_ingress.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name" = "${var.project_name} Inbound Permissive SG"
  }
}

resource "aws_lb" "alb_ingress" {
  name               = "${var.project_name}-Inbound-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_permissive.id]
  subnets            = [aws_subnet.sn_ingress_alb_a.id, aws_subnet.sn_ingress_alb_b.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "albl_ingress" {
  load_balancer_arn = aws_lb.alb_ingress.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_ingress.arn
  }
}

resource "aws_lb_target_group" "tg_ingress" {
  name     = "${var.project_name}-Inbound-Target-Group"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.vpc_ingress.id
}

resource "aws_lb_target_group_attachment" "tga_ingress" {
  target_group_arn = aws_lb_target_group.tg_ingress.arn
  target_id        = aws_instance.ins_spoke.private_ip 
  port             = 80
  availability_zone  = "all"
}
