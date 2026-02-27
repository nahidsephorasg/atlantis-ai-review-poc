# Dev VPC
# Creates the VPC for the dev environment

terraform {
  source = "../../../modules//vpc"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  name               = "dev-platform"
  cidr_block         = "10.10.0.0/16"
  private_subnets    = ["10.10.1.0/24", "10.10.2.0/24"]
  public_subnets     = ["10.10.101.0/24", "10.10.102.0/24"]
  availability_zones = ["ap-southeast-1a", "ap-southeast-1b"]
}
