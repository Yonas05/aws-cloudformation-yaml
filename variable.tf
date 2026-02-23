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
