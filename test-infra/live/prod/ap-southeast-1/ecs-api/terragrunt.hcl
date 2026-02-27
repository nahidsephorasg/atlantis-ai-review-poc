# Prod ECS API Service
# Deploys the API service on ECS Fargate in the production environment
#
# TEST SCENARIOS for AI Review:
#
# Scenario 1 — CPU/Memory Increase (cost impact):
#   Change cpu from 512 to 1024 and memory from 1024 to 2048.
#   The AI reviewer should flag the cost increase in prod.
#
# Scenario 2 — Desired count to 0 (accidental scale-down):
#   Change desired_count from 3 to 0.
#   The AI reviewer should flag this as CRITICAL in prod.
#
# Scenario 3 — Missing tags:
#   Remove a required tag from the tags map.
#   The AI reviewer should flag missing required tags.

terraform {
  source = "../../../modules//ecs-service"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id             = "vpc-mock-prod-00000000"
    private_subnet_ids = ["subnet-mock-prod-priv-1", "subnet-mock-prod-priv-2"]
    public_subnet_ids  = ["subnet-mock-prod-pub-1", "subnet-mock-prod-pub-2"]
    vpc_cidr_block     = "10.20.0.0/16"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "sg" {
  config_path = "../sg"

  mock_outputs = {
    security_group_id  = "sg-mock-prod-00000000"
    security_group_arn = "arn:aws:ec2:ap-southeast-1:000000000000:security-group/sg-mock-prod-00000000"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  name               = "api"
  container_image    = "nginx:1.25-alpine"
  container_port     = 443
  health_check_path  = "/health"
  desired_count      = 3
  subnet_ids         = dependency.vpc.outputs.private_subnet_ids
  security_group_ids = [dependency.sg.outputs.security_group_id]
  vpc_id             = dependency.vpc.outputs.vpc_id

  # ---------------------------------------------------------
  # TEST: Change these values to simulate AI review triggers
  # Scenario 1: cpu = 512 → 1024, memory = 1024 → 2048
  # Scenario 2: desired_count = 3 → 0
  # ---------------------------------------------------------
  cpu    = 512
  memory = 1024

  environment_variables = [
    {
      name  = "APP_ENV"
      value = "production"
    },
    {
      name  = "LOG_LEVEL"
      value = "warn"
    }
  ]

  tags = {
    Service    = "api"
    Team       = "platform"
    CostCenter = "CC-1234"
  }
}
