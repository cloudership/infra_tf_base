resource "aws_ecs_cluster" "default" {
  name = "${var.project_name}-default"

  tags = local.tags
}

data "aws_iam_policy" "ecs_task_execution_role" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_execution" {
  name                = "${var.project_name}-ecs-task-execution-role"
  managed_policy_arns = [data.aws_iam_policy.ecs_task_execution_role.arn]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = local.tags
}
