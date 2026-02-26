provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0f3caa1cf4417e51b"
  instance_type = var.instance_type
  tags = {
    Name = var.instance_name
  }

}
resource "aws_instance" "Private_instance" {
  ami           = "ami-0f3caa1cf4417e51b"
  instance_type = var.instance_private_type
  tags = {
    Name = var.private_instance
  }


}


resource "vpc_peering_connection" "vpc_peering" {
  vpc_id      = aws_vpc.demo_vpc_a.id
  peer_vpc_id = aws_vpc.demo_vpc_b.id
  auto_accept = true
  tags = {
    Name = "vpc-a-to-vpc-b-peering"
  }

}

resource "aws_vpc_peering_connection_options" "requester" {
  vpc_peering_connection_id = vpc_peering_connection.vpc_peering.id
  requester {
    allow_remote_vpc_dns_resolution = true
  }

}

resource "aws_vpc_peering_connection_options" "accepter" {
  vpc_peering_connection_id = vpc_peering_connection.vpc_peering.id
  accepter {
    allow_remote_vpc_dns_resolution = true
  }

}

resource "aws_route" "peering-a-to-b" {
  route_table_id            = aws_route_table.demo_vpc_a_public.id
  destination_cidr_block    = aws_vpc.demo_vpc_b.cidr_block
  vpc_peering_connection_id = vpc_peering_connection.vpc_peering.id
}

resource "aws_route" "peering-b-to-a" {
  route_table_id            = aws_route_table.demo_vpc_b_public.id
  destination_cidr_block    = aws_vpc.demo_vpc_a.cidr_block
  vpc_peering_connection_id = vpc_peering_connection.vpc_peering.id
}


resource "aws_security_group" "vpc_a_sg" {
  name   = "vpc-a-sg"
  vpc_id = aws_vpc.demo_vpc_a.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "vpc-a-sg"
  }
}
resource "aws_security_group" "vpc_b_sg" {
  name   = "vpc-b-sg"
  vpc_id = aws_vpc.demo_vpc_b.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "vpc-b-sg"
  }
}

resource "aws_security_group_rule" "allow_b_to_a" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpc_a_sg.id
  source_security_group_id = aws_security_group.vpc_b_sg.id

}
resource "aws_security_group_rule" "allow_a_to_b" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpc_b_sg.id
  source_security_group_id = aws_security_group.vpc_a_sg.id

}

resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "ec2_a" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.demo-subnet-a.id
  vpc_security_group_ids = [aws_security_group.sg_vpc_a.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name
  tags                   = { Name = "ec2-vpc-a" }
}

resource "aws_instance" "ec2_b" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.demo-subnet-b.id
  vpc_security_group_ids = [aws_security_group.sg_vpc_b.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name
  tags                   = { Name = "ec2-vpc-b" }
}
