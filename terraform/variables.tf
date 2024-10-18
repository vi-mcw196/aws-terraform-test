# variables.tf

variable "aws_region" {
  description = "The AWS region to deploy resources"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "build_instance_name" {
  description = "Name tag for the BUILD instance"
  default     = "BuildServer"
}

variable "test_instance_name" {
  description = "Name tag for the TEST instance"
  default     = "TestServer"
}

variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}
