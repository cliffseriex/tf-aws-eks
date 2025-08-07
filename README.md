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


cd environments/stag/vpc
terragrunt plan
terragrunt apply

cd environments/stag/alb
terragrunt plan
terragrunt apply

cd environments/stag/eks
terragrunt plan
terragrunt apply


Deploy Production Environment
similiar to the stag


4. Deploy Applications (Staging Only)
chmod +x webapp/env_setup.sh
./webapp/env_setup.sh


#  Create ECR repository
aws ecr create-repository --repository-name hello-world --region us-east-1

# update your kubeconfig
aws eks update-kubeconfig --name webapp-cluster --region $AWS_REGION

# Create a ConfigMap to allow the IAM user to access the cluster
cat > aws-auth-patch.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapUsers: |
    - userarn: arn:aws:iam::$AWS_ACCOUNT_ID:user/github-actions-deploy
      username: github-actions-deploy
      groups:
        - system:masters
EOF

# Apply the ConfigMap patch
kubectl apply -f aws-auth-patch.yaml

# Create namespaces
kubectl create namespace hello-world-staging || true
kubectl create namespace hello-world-production || true


# Install AWS Load Balancer Controller (if not already installed)
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install the controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=webapp-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller || true


## Add Secrets to GitHub Repository
Go to your GitHub repository settings:

Navigate to Settings → Secrets and variables → Actions
# If using GitHub CLI:
gh secret set AWS_ACCESS_KEY_ID --body "YOUR_ACCESS_KEY_ID"
gh secret set AWS_SECRET_ACCESS_KEY --body "YOUR_SECRET_ACCESS_KEY"


# Or add manually in GitHub UI:
# - AWS_ACCESS_KEY_ID: (from step 1.2)
# - AWS_SECRET_ACCESS_KEY: (from step 1.2)