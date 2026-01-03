# main.tf - Creates ECS infrastructure on AWS (CI/CD compatible)

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# -----------------------------
# Networking (Default VPC)
# -----------------------------
data "aws_vpc" "youngyz" {
  default = true
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.youngyz.id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

# -----------------------------
# ECS Cluster
# -----------------------------
resource "aws_ecs_cluster" "youngyz" {
  name = var.cluster_name

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
    Project     = "youngyz-devops"
  }
}

# -----------------------------
# CloudWatch Logs
# -----------------------------
resource "aws_cloudwatch_log_group" "youngyzapp" {
  name              = "/ecs/${var.cluster_name}-youngyzapp"
  retention_in_days = 7

  tags = {
    Name        = "${var.cluster_name}-youngyzapp-logs"
    Environment = var.environment
  }
}

# -----------------------------
# IAM Role (ECS Execution Role)
# -----------------------------
resource "aws_iam_role" "ecs_execution_role" {
  name = "youngyz-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = {
    Name        = "youngyz-ecs-execution-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# -----------------------------
# Security Group (PORT 3001)
# -----------------------------
resource "aws_security_group" "youngyzapp_sg" {
  name        = "${var.cluster_name}-youngyzapp-sg"
  description = "Security group for youngyz app"
  vpc_id      = data.aws_vpc.youngyz.id

  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.cluster_name}-youngyzapp-sg"
    Environment = var.environment
  }
}

# -----------------------------
# ECS Task Definition
# -----------------------------
resource "aws_ecs_task_definition" "youngyzapp" {
  depends_on = [
    aws_iam_role_policy_attachment.ecs_execution_role_policy
  ]

  family                   = "youngyzapp"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name  = "youngyzapp"
    image = "nginx:latest" # placeholder (CI/CD replaces image)
    essential = true

    portMappings = [{
      containerPort = 3001
      protocol      = "tcp"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.youngyzapp.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }

    environment = [{
      name  = "ENVIRONMENT"
      value = var.environment
    }]
  }])

  tags = {
    Name        = "youngyzapp-task"
    Environment = var.environment
  }
}

# -----------------------------
# ECS Service
# -----------------------------
resource "aws_ecs_service" "youngyzapp" {
  name            = "${var.cluster_name}-youngyzapp-service"
  cluster         = aws_ecs_cluster.youngyz.id
  task_definition = aws_ecs_task_definition.youngyzapp.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.public_subnets.ids
    security_groups  = [aws_security_group.youngyzapp_sg.id]
    assign_public_ip = true
  }

  tags = {
    Name        = "${var.cluster_name}-youngyzapp-service"
    Environment = var.environment
  }
}

# -----------------------------
# ECR Repository (CI/CD MATCH)
# -----------------------------
resource "aws_ecr_repository" "youngyzapp" {
  name                 = "my-youngyzapp"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "my-youngyzapp"
    Environment = var.environment
  }
}
