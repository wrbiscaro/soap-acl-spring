resource "aws_lb" "soap_acl_alb" {
  name               = "soap-acl-alb"
  security_groups    = [aws_security_group.sg_alb_soap_acl.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "soap_acl_listener" {
  load_balancer_arn = aws_lb.soap_acl_alb.arn
  port              = "8080"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.soap_acl_tg.arn
  }
}

resource "aws_lb_target_group" "soap_acl_tg" {
  name        = "soap-acl-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    healthy_threshold   = 5
    interval            = 30
    unhealthy_threshold = 2
    timeout             = 5
    path                = "/actuator/health"
    matcher             = 200 # http status code
  }
}

output "alb_dns_name" {
  value = aws_lb.soap_acl_alb.dns_name
}