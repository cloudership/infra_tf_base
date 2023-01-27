resource "aws_ecs_cluster" "default" {
  name = "${var.project_name}-default"

  tags = local.tags
}

resource "aws_ecs_task_definition" "sample_web_app" {
  family                   = "sample-web-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      name      = "sample-web-app"
      image     = "yeasy/simple-web:latest"
      cpu       = 256
      memory    = 512
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
  ])

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  tags = local.tags
}

resource "aws_ecs_service" "sample_web_app" {
  name            = "sample-web-app"
  cluster         = aws_ecs_cluster.default.arn
  task_definition = aws_ecs_task_definition.sample_web_app.arn
  desired_count   = 1

  network_configuration {
    subnets = module.vpc.private_subnets
  }

  tags = local.tags
}
