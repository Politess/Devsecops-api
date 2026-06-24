variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"
}

variable "app_name" {
  description = "Application name — used as a prefix for all resources"
  type        = string
  default     = "devsecops-api"
}

variable "image_uri" {
  description = "Full ECR image URI including tag — passed in by the pipeline"
  type        = string
}

variable "github_repo" {
  description = "GitHub repo in org/repo format for OIDC trust policy"
  type        = string
  default     = "Politess/devsecops-api"
}
