module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name               = "soap-acl-spring-${var.env}"
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }
}

resource "aws_ecs_task_definition" "soap_acl_spring" {
  family                   = "soap-acl-spring-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.soap_acl_ecs_role.arn
  container_definitions = jsonencode(
    [
      {
        "name"      = "soap-acl-spring-container"
        "image"     = "638260411513.dkr.ecr.sa-east-1.amazonaws.com/soap-acl-spring-${var.env}:latest"
        "cpu"       = 256
        "memory"    = 512
        "essential" = true
        "portMappings" = [
          {
            "containerPort" = 8080
            "hostPort"      = 8080
          }
        ]
        "logConfiguration" = {
            "logDriver" = "awslogs"
            "options" = {
                "awslogs-create-group"  = "true"
                "awslogs-group"         = "/ecs/soap-acl-spring-${var.env}"
                "awslogs-region"        = "sa-east-1"
                "awslogs-stream-prefix" = "ecs"
            }
        }
      }
    ]
  )
}

resource "aws_ecs_service" "soap_acl_spring" {
  name            = "soap-acl-spring-service"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.soap_acl_spring.arn
  desired_count   = 3

  load_balancer {
    target_group_arn = aws_lb_target_group.soap_acl_tg.arn
    container_name   = "soap-acl-spring-container"
    container_port   = 8080
  }

  network_configuration {
      subnets = module.vpc.private_subnets
      security_groups = [aws_security_group.sg_private_soap_acl.id]
  }

  capacity_provider_strategy {
      capacity_provider = "FARGATE"
      weight = 1 # 100/100
  }
}