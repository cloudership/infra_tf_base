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

module "sample_web_app_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name   = "sample-web-app"
  vpc_id = module.vpc.vpc_id

  egress_rules = ["all-all"]

  computed_ingress_with_source_security_group_id = [
    { rule = "http-80-tcp", source_security_group_id = local.public_alb_sg_internal_id }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  tags = local.tags
}

resource "aws_alb_target_group" "sample_web_app" {
  name                 = "sample-web-app"
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  ip_address_type      = "ipv4"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = 60
  tags                 = local.tags
}

resource "aws_ecs_service" "sample_web_app" {
  name            = "sample-web-app"
  cluster         = aws_ecs_cluster.default.arn
  task_definition = aws_ecs_task_definition.sample_web_app.arn
  launch_type     = "FARGATE"

  desired_count        = var.enable_expensive ? 1 : 0
  force_new_deployment = true

  network_configuration {
    subnets          = module.vpc.public_subnets
    assign_public_ip = true
    security_groups  = [module.sample_web_app_sg.security_group_id]
  }

  # Use dynamic block to remove this if enable_expensive == false
  load_balancer {
    target_group_arn = aws_alb_target_group.sample_web_app.arn
    container_name   = "sample-web-app"
    container_port   = 80
  }

  tags = merge(local.tags, { Name = "sample-web-app" })

  depends_on = [module.public_alb]
}

resource "aws_alb_listener_rule" "sample_web_app" {
  listener_arn = local.public_alb_https_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.sample_web_app.arn
  }

  condition {
    host_header {
      values = ["sample-web-app.*"]
    }
  }

  count = var.enable_expensive ? 1 : 0

  tags = local.tags
}

resource "aws_route53_record" "sample_web_app" {
  name    = "sample-web-app"
  type    = "A"
  zone_id = aws_route53_zone.public.id

  alias {
    evaluate_target_health = false
    name                   = module.public_alb.lb_dns_name
    zone_id                = module.public_alb.lb_zone_id
  }

  count = var.enable_expensive ? 1 : 0
}
