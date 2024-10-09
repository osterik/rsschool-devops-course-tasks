variable "aws_region" {
  description = "Target AWS region."
  type        = string
  default     = "eu-central-1"
}

# variable "project_name" {
#   description = "Project name"
#   type        = string
# }

variable "env_name" {
  description = "Environment name"
  type        = string
}


### VPC #######################################################################
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "database_subnets" {
  description = "A list of database subnets"
  type        = list(string)
  default     = []
}
