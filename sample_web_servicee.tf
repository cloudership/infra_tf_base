resource "aws_ecs_task_definition" "sample_web_app" {
  family                   = "sample-web-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"

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
          protocol      = "tcp"

        }
      ]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/test",
          awslogs-region        = data.aws_region.current.name,
          awslogs-stream-prefix = "sample-web-app",
        }
      },
    },
  ])

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  tags = local.tags
}

resource "aws_security_group" "sample_web_app_allow_80" {
  name   = "sample-web-app"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "80 from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.tags, { Name = "sample-web-app" })
}

resource "aws_ecs_service" "sample_web_app" {
  name            = "sample-web-app"
  cluster         = aws_ecs_cluster.default.arn
  task_definition = aws_ecs_task_definition.sample_web_app.arn
  launch_type     = "FARGATE"

  desired_count        = 0
  force_new_deployment = true

  network_configuration {
    subnets          = module.vpc.public_subnets
    assign_public_ip = true
    security_groups  = [aws_security_group.sample_web_app_allow_80.id]
  }

  tags = merge(local.tags, { Name = "sample-web-app" })
}
