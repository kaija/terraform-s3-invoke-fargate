variable "aws_region" {
  description = "The AWS region to deploy to (e.g. us-west-2)"
  type        = string
}

variable "account_stage" {
  description = "The AWS account stage"
  type        = string
  default     = "production"
}

variable "project" {
  description = "The project name"
  type        = string
}

variable "environment" {
  description = "The project environment"
  type        = string
}

variable "image_tag" {
  description = "The docker image tag"
  type        = string
  default     = "latest"
}
