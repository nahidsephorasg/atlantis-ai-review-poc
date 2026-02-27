# Dev Security Group for API service
# Defines ingress/egress rules for the ECS API service

terraform {
  source = "../../../modules//security-group"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  name        = "dev-api"
  vpc_id      = dependency.vpc.outputs.vpc_id
  description = "Security group for dev API ECS service"

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["10.10.0.0/16"]
      description = "Allow HTTP from VPC"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.10.0.0/16"]
      description = "Allow HTTPS from VPC"
    }
  ]
}
