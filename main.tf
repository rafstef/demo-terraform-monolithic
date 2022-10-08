terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "4.23.0"
        }  
    }
    backend "s3" {
        bucket = "202210-demo-terraform"
        key    = "demo-terraform-monolithic"
        region = "eu-central-1"
    }
}

data "aws_ami" "ubuntu" {
  most_recent = "true"
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_vpc" "main" {
  cidr_block       = "${lookup(local.cidr, terraform.workspace)}"

  tags = {
    Name = "demo-monolithic-${lookup(local.env, terraform.workspace)}"
  }
}

resource "aws_subnet" "private" {
  count = 3
  vpc_id     = aws_vpc.main.id
  cidr_block = element("${lookup(local.private_subnets, terraform.workspace)}",count.index)
  availability_zone = element("${lookup(local.azs, terraform.workspace)}",count.index)

  tags = {
    Name = "private-${count.index}"
  }
}

resource "aws_subnet" "public" {
  count = 3
  vpc_id     = aws_vpc.main.id
  cidr_block = element("${lookup(local.public_subnets, terraform.workspace)}",count.index)
  availability_zone = element("${lookup(local.azs, terraform.workspace)}",count.index)
  tags = {
    Name = "public-${count.index}"
  }
}


# resource "aws_instance" "test-frontend" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t3.micro"

#   tags = {
#     Name = "demo-monolithic-frontend"
#   }
# }