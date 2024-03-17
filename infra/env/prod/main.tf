module "prod" {
    source = "../../modules"

    ecr_repo_name = "soap-acl-spring-prod"
    env = "prod"
}

output "soap_acl_alb_dns_name" {
  value = module.prod.alb_dns_name
}