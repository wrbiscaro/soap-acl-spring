terraform {
  backend "s3" {
    bucket = "soap-acl-spring-terraform"
    key    = "prod/terraform.tfstate"
    region = "sa-east-1"
  }
}