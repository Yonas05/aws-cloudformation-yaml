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
  vpc_id        = aws_vpc.demo_vpc_a.id
  peer_vpc_id   = aws_vpc.demo_vpc_b.id
  auto_accept   = true
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