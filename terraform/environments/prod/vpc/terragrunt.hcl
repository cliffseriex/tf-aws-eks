include "root" {
  path = find_in_parent_folders()
}

locals {
  env_vars = yamldecode(file("../env.yaml"))
}

terraform {
  source = "../../modules//vpc"
}

inputs = {
  environment     = "prod"
  vpc_cidr        = local.env_vars.vpc_config.cidr_block
  azs             = local.env_vars.vpc_config.azs
  public_subnets  = local.env_vars.vpc_config.public_subnets
  private_subnets = local.env_vars.vpc_config.private_subnets
  cluster_name    = "webapp-cluster-prod"
}