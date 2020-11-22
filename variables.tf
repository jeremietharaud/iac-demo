# MANDATORY VARIABLES (DOES NOT CHANGE BETWEEN ENVS)
variable "region" {
  type        = string
  description = "Name of the region to use"
  default     = "eu-west-1"
}

variable "repository" {
  type        = string
  description = "Name of the repository"
  default     = "https://github.com/jeremietharaud/iac-demo"
}


# ENVIRONMENT SPECIFIC VARIABLES
variable "vpc_cidr" {
  type        = string
  description = "Network definition for the VPC"
}

variable "azs" {
  type        = list(string)
  description = "List of availability zones"
}

variable "public_subnet_cidr" {
  type        = list(string)
  description = "List of public subnet cidr"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags that will be added to created resources."
}

variable "domain_name" {
  type        = string
  description = "Name of the domain"
}

variable "public_key" {
  type        = string
  description = "Public key used by instances"
}

variable "instance_type" {
  type        = string
  description = "Type of instance"
}

variable "cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks for connection to instances"
}

variable "asg_instances_desired_capacity" {
  type        = string
  description = "The number of Amazon EC2 instances that should be running in the group"
}

variable "asg_instances_min_size" {
  type        = string
  description = "The minimum number of EC2 that should be running in the ASG"
}

variable "asg_instances_max_size" {
  type        = string
  description = "The maximum number of EC2 that should be running in the ASG"
}

variable "application_port" {
  type        = string
  description = "Listening port of the application"
}

variable "force_https" {
  type        = string
  description = "Force https with certificate on load balancer"
}