# Dev ECS API Service
# Deploys the API service on ECS Fargate in the dev environment
#
# TEST SCENARIO: Change cpu from 256 to 512 and memory from 512 to 1024
# to simulate a PR that triggers the AI review.

terraform {
  source = "../../../modules//ecs-service"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id             = "vpc-mock-dev-00000000"
    private_subnet_ids = ["subnet-mock-dev-priv-1", "subnet-mock-dev-priv-2"]
    public_subnet_ids  = ["subnet-mock-dev-pub-1", "subnet-mock-dev-pub-2"]
    vpc_cidr_block     = "10.10.0.0/16"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "sg" {
  config_path = "../sg"

  mock_outputs = {
    security_group_id  = "sg-mock-dev-00000000"
    security_group_arn = "arn:aws:ec2:ap-southeast-1:000000000000:security-group/sg-mock-dev-00000000"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  name               = "api"
  container_image    = "nginx:1.25-alpine"
  container_port     = 80
  health_check_path  = "/health"
  desired_count      = 1
  subnet_ids         = dependency.vpc.outputs.private_subnet_ids
  security_group_ids = [dependency.sg.outputs.security_group_id]
  vpc_id             = dependency.vpc.outputs.vpc_id

  # ---------------------------------------------------------
  # TEST: Change these values to simulate an AI review trigger
  # Original:  cpu = 256, memory = 512
  # Change to: cpu = 512, memory = 1024
  # ---------------------------------------------------------
  cpu    = 512
  memory = 1024

  environment_variables = [
    {
      name  = "APP_ENV"
      value = "dev"
    },
    {
      name  = "LOG_LEVEL"
      value = "debug"
    }
  ]
}
