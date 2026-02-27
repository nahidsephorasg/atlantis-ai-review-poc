# Prod Security Group for API service
# Defines strict ingress/egress rules for the production ECS API service
#
# NOTE: In real scenarios, someone might manually add an SG rule in the AWS console
# (e.g., allowing port 3306 from a specific CIDR for database debugging).
# That manually-added rule would NOT be in this config, so `terraform plan` would
# show it being destroyed — which is exactly what the AI reviewer should catch.

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
  name        = "prod-api"
  vpc_id      = dependency.vpc.outputs.vpc_id
  description = "Security group for prod API ECS service"

  ingress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.20.0.0/16"]
      description = "Allow HTTPS from VPC"
    }
    # ----------------------------------------------------------
    # MISSING: A rule for port 3306 that was added manually in AWS
    # console. When terraform plan runs, it will show this manual
    # rule being DESTROYED. The AI reviewer should flag this.
    #
    # To simulate: add this rule manually in AWS, then run plan.
    # The plan output will show:
    #   - aws_security_group_rule.manual_db_access will be destroyed
    # ----------------------------------------------------------
  ]
}
