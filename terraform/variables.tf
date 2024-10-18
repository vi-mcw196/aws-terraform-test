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

variable "github_owner" {
  description = "GitHub repository owner (username or organization)"
  type        = string
  default     = "pwr-twwo"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "lab3-grupa11-3"
}
