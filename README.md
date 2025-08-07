# AWS EKS Infrastructure with Terragrunt

This project provisions a complete AWS infrastructure for hosting containerized web applications using EKS, with separate production and staging environments.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.5.0
- Terragrunt >= 0.48.0
- kubectl >= 1.28
- Helm >= 3.12.0

## Architecture Overview

The infrastructure includes:
- VPC with public and private subnets across 2 AZs
- EKS cluster with auto-scaling node groups
- Application Load Balancer for ingress
- CloudWatch monitoring for metrics
- Separate prod/stag environments
- 2 sample web applications in staging with different auto-scaling configurations

## Project Structure
├── terragrunt.hcl          # Root configuration
├── environments/           # Environment-specific configs
├── modules/               # Terraform modules

## Setup Instructions

### 1. Initialize Backend Resources

First, create the S3 bucket and DynamoDB table for Terraform state:

```bash
# Run 


1. Configure Environment Variables
export TG_BUCKET_PREFIX="thrive"
export AWS_REGION="us-east-1"

2. Run the backend setup
.\setup-backend.sh

3. Deploy Infrastructure
Deploy Staging Environment

cd environments/stag

# Plan the deployment
cd environments/stag/vpc
terragrunt plan
terragrunt apply

cd environments/stag/alb
terragrunt plan
terragrunt apply

cd environments/stag/eks
terragrunt plan
terragrunt apply

# Configure kubectl
aws eks update-kubeconfig --name webapp-cluster --region us-east-1


Deploy Production Environment
similiar to the stag


4. Deploy Applications (Staging Only)
chmod +x webapp/env_setup.sh
./webapp/env_setup.sh


