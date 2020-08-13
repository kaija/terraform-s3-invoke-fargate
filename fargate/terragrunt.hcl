locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  account_name  = local.account_vars.locals.account_name
  account_id    = local.account_vars.locals.aws_account_id
  aws_region    = local.region_vars.locals.aws_region
  account_stage = local.account_vars.locals.account_stage
  env           = local.environment_vars.locals.environment
  tenant        = local.environment_vars.locals.tenant
  project_name  = local.project_vars.locals.project_name
  project_alt   = local.project_vars.locals.project_alt
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  allowed_account_ids = ["${local.account_id}"]
}
provider "aws" {
  region = "us-east-1"
  allowed_account_ids = ["${local.account_id}"]
  alias = "acm"
}
EOF
}


remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "tulen-terraform-${local.account_stage}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "tulen-terraform-${local.account_stage}"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = merge(
  local.project_vars.locals,
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
)
