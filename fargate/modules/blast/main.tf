terraform {
  required_providers {
    aws = {
      version = "3.0.0"
    }
  }
}

data "aws_vpc" "default" {
  filter {
    name   = "tag:Name"
    values = ["default"]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.default.id
  #filter {
  #  name   = "tag:Tenant"
  #  values = [var.tenant]
  #}
}

locals {
  resource_name  = "${var.project}-${var.environment}-worker"
  log_group_name = "/ecs/${local.resource_name}"
}

resource "aws_ecs_cluster" "blast" {
  name               = "${var.project}-${var.environment}-worker"
  capacity_providers = ["FARGATE"]
}

resource "aws_iam_role" "task_role" {
  name = "${var.project}-${var.environment}-worker"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ]
}
EOF
  tags = {
    Name        = "${var.project}-${var.environment}-worker"
    Environment = var.environment
  }
}

resource "aws_iam_policy" "task_base_policy" {
  name        = "${local.resource_name}-base-policy"
  path        = "/"
  description = ""

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "task-execution-policy-attach" {
  role       = aws_iam_role.task_execute_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task_execute_role" {
  name = "${var.project}-${var.environment}-EcsTaskExecute"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ]
}
EOF
  tags = {
    Name        = "${var.project}-${var.environment}-EcsTaskExecute"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "base-policy-attach" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.task_base_policy.arn
}

# ECS

resource "aws_ecs_task_definition" "this" {
  family                = local.resource_name
  task_role_arn         = aws_iam_role.task_role.arn
  execution_role_arn    = aws_iam_role.task_execute_role.arn
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                   = 512
  memory                = 1024
  tags                  = {}
  container_definitions = <<TASK_DEFINITION
  [
    {
      "name": "worker",
      "essential": true,
      "startTimeout": 30,
      "stopTimeout": 30,
      "image": "kaija/s3read:${var.image_tag}",
      "cpu": 512,
      "memory": 800,
      "memoryReservation": 128,
      "environment": [
        {
          "name": "CONN_POOL_MAX",
          "value": "2"
        }
      ],
      "mountPoints": [],
      "portMappings": [],
      "volumesFrom": []
    }
  ]
  TASK_DEFINITION
}

resource "aws_cloudwatch_log_group" "this" {
  name = local.log_group_name

  retention_in_days = 30
}
