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
  source = "../../../modules//eks"
}

inputs = {
  environment        = "stag"
  cluster_name       = "webapp-cluster-stag"
  cluster_version    = local.env_vars.eks_config.cluster_version
  vpc_id            = dependency.vpc.outputs.vpc_id
  public_subnet_ids = dependency.vpc.outputs.public_subnet_ids
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
  security_group_id = dependency.vpc.outputs.eks_security_group_id
  node_groups       = local.env_vars.eks_config.node_groups
}