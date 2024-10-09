variable "aws_region" {
  description = "Target AWS region."
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "env_name" {
  description = "Environment name"
  type        = string
}

variable "github_org" {
  description = "Organization(user) name on github.com"
  type        = string
  default     = "osterik"
}

variable "github_repo" {
  description = "Repository name on github.com"
  type        = string
}
