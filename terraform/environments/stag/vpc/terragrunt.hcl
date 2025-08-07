include "root" {
  path = "../../../root.hcl"
}

terraform {
  source = "../../../modules//vpc"
}

inputs = {
  environment     = "stag"
  vpc_cidr        = "10.1.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets = ["10.1.10.0/24", "10.1.11.0/24"]
  cluster_name    = "webapp-cluster-stag"
}
