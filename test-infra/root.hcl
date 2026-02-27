# Root Terragrunt configuration
# All child terragrunt.hcl files inherit from this

locals {
  # Parse the file path to extract environment and region
  # Expected path: live/<env>/<region>/<component>/terragrunt.hcl
  path_parts  = split("/", path_relative_to_include())
  environment = local.path_parts[1]
  region      = local.path_parts[2]

  # Common tags applied to all resources
  common_tags = {
    Environment = local.environment
    ManagedBy   = "terragrunt"
    Team        = "platform"
    Project     = "atlantis-poc"
  }
}

# Configure remote state (using local backend for testing)
remote_state {
  backend = "local"
  config = {
    path = "${get_parent_terragrunt_dir()}/state/${path_relative_to_include()}/terraform.tfstate"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.region}"

  default_tags {
    tags = {
      Environment = "${local.environment}"
      ManagedBy   = "terragrunt"
    }
  }
}
EOF
}

# Global inputs passed to all modules
inputs = {
  environment = local.environment
  tags        = local.common_tags
}
