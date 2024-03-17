resource "aws_security_group" "sg_alb_soap_acl" {
  # sg para o alb
  name        = "alb-soap-acl-sg"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "sg_ingress_rule_alb_soap_acl" {
  # permite a entrada de todos os ips na porta 8080 tcp
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_alb_soap_acl.id
}

resource "aws_security_group_rule" "sg_egress_rule_alb_soap_acl" {
  # permite a saida de todos os ips, portas e protocolos
  type              = "egress"
  from_port         = 0 
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_alb_soap_acl.id
}

resource "aws_security_group" "sg_private_soap_acl" {
  name        = "private-soap-acl-sg"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "sg_ingress_rule_private_soap_acl" {
  # permite a entrada de requisicoes do sg do alb
  type                     = "ingress"
  from_port                = 0 
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_alb_soap_acl.id
  security_group_id        = aws_security_group.sg_private_soap_acl.id
}

resource "aws_security_group_rule" "sg_egress_rule_private_soap_acl" {
  # permite a saida de todos os ips, portas e protocolos
  type              = "egress"
  from_port         = 0 
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_private_soap_acl.id
}