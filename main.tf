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
