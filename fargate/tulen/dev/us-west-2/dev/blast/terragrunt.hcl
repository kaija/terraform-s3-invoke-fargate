locals {
  project_vars     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  env              = local.environment_vars.locals.environment
  tenant           = local.environment_vars.locals.tenant
  project_name     = local.project_vars.locals.project_name
  project_alt      = local.project_vars.locals.project_alt
}

terraform {
  source = "../../../../../modules/blast"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  project               = local.project_name
  project_alt           = local.project_alt
  environment           = local.env
  tenant                = local.tenant
}
