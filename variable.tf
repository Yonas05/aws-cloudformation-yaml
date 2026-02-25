variable "instance_name" {
  description = "value fo the Ec2 instance's Name tag."
  type        = string
  default     = "learn-terraform-aws"
}
variable "instance_type" {

    description = "The type of EC2 instance to create."
    type        = string
    default     = "t3.micro"
  
}

variable "private_instance" {
  type = string
  description = "private instance for database server"
  default = "database_server"
  
}
variable "instance_private_type" {
  description = "The type of EC2 instance to create for database server."
  type        = string
  default     = "t3.micro"
  
}
variable "region" {
  type = string
  description = "AWS region to deploy resources"

  
}
variable "demo_vpc_a_cidr" {
  description = "CIDR block for the first VPC"
  type        = string
}
variable "demo_vpc_b_cidr" {
  description = "CIDR block for the second VPC"
  type        = string
} 
variable "demo_subnet_a_cidr" {
  description = "CIDR block for the first subnet"
  type        = string
}
variable "demo_subnet_b_cidr" {
  description = "CIDR block for the second subnet"
  type        = string
}
