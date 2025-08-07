include "root" {
  path = "../../../root.hcl"
}

dependency "vpc" {
  config_path = "../vpc"
}

locals {
  env_vars = yamldecode(file("../env.yaml"))
}

terraform {
  source = "../../../modules//alb"
}

inputs = {
  environment                = "stag"
  vpc_id                    = dependency.vpc.outputs.vpc_id
  public_subnet_ids         = dependency.vpc.outputs.public_subnet_ids
  internal                  = local.env_vars.alb_config.internal
  enable_deletion_protection = local.env_vars.alb_config.enable_deletion_protection
}