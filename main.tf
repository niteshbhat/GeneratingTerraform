provider "aws" {
  region = var.region
}
resource "aws_instance" "example" {
 tags = {
    Name = var.instance_name
  }
}

