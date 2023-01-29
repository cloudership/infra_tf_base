resource "aws_ecs_cluster" "default" {
  name = "${var.project_name}-default"

  tags = local.tags
}
