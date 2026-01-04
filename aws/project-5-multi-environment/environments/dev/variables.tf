# Development environment variables

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "container_image" {
  description = "Docker image to run"
  type        = string
  default     = "958421185668.dkr.ecr.us-east-1.amazonaws.com/my-youngyzapp:latest"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 3001
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
} 