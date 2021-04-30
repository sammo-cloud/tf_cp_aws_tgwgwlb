resource "aws_instance" "ins_spoke" {
    ami                         = "ami-0cfcf03250288518d"
    availability_zone           = "${var.aws_region}a"
    ebs_optimized               = true
    instance_type               = "t3.nano"
    monitoring                  = false
    key_name                    = "${var.project_name} TPOT Key"
    subnet_id                   = aws_subnet.sn_spoke_public_a.id
    vpc_security_group_ids      = [aws_security_group.sg_spoke.id]
    associate_public_ip_address = true
    source_dest_check           = true

    root_block_device {
        volume_type           = "gp2"
        volume_size           = 10
        delete_on_termination = true
    }

  tags = {
    Name = "${var.project_name} Spoke Instance"
  }
}

resource "aws_security_group" "sg_spoke" {
  name        = "${var.project_name}-Permissive"
  description = "${var.project_name} Permissive"
  vpc_id      = aws_vpc.vpc_spoke.id

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
    Name = "${var.project_name} Spoke Permissive SG"
  }
}
