# main.tf

# Specify the AWS provider
provider "aws" {
  region = var.aws_region
}

# Generate an SSH key pair for EC2 instances
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS Key Pair with the public key
resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

# Security Group to allow SSH and HTTP
resource "aws_security_group" "web_server_sg" {
  name        = "web-server-sg"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 5000
    to_port          = 5000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebServerSG"
  }
}

# Data Source for the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# BUILD Instance
resource "aws_instance" "build_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.web_server_sg.id]
  key_name                    = aws_key_pair.ec2_key.key_name

  tags = {
    Name = var.build_instance_name
  }

  user_data = templatefile("../scripts/build-user-data.sh.tpl", {
    github_token = var.github_token
  })
}

# TEST Instance
resource "aws_instance" "test_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.web_server_sg.id]
  key_name                    = aws_key_pair.ec2_key.key_name

  tags = {
    Name = var.test_instance_name
  }

  # Ensure that the TEST instance waits for the BUILD instance to complete
  depends_on = [aws_instance.build_instance]

  user_data = templatefile("../scripts/test-user-data.sh.tpl", {
    github_token = var.github_token
  })
}
