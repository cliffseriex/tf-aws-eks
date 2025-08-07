# AWS EKS Infrastructure with Terragrunt & Node.js Application

This project provisions AWS infrastructure using Terraform/Terragrunt and deploys a containerized Node.js application with CI/CD via GitHub Actions.

## Prerequisites

- AWS CLI configured with credentials
- Terraform >= 1.5.0
- Terragrunt >= 0.48.0
- kubectl >= 1.28
- Docker
- Node.js >= 18

## Project Structure

```
├── .github/workflows/     # CI/CD pipeline
├── terraform/            # Infrastructure modules
│   ├── environments/     # Environment configs
│   ├── modules/         # Terraform modules
│   └── root.hcl        # Root Terragrunt config
└── webapp/              # Application code
    ├── k8s/            # Kubernetes manifests
    ├── src/            # Node.js application
    └── Dockerfile      # Container definition
```

## Quick Start

### 1. Setup Backend (One-time)

```bash
# Create S3 bucket for Terraform state
aws s3api create-bucket \
  --bucket thrive-terraform-state-$(aws sts get-caller-identity --query Account --output text) \
  --region us-east-1

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

### 2. Deploy Infrastructure

```bash
# Set environment variables
export TG_BUCKET_PREFIX="thrive"
export AWS_REGION="us-east-1"

# Deploy staging environment
cd terraform/environments/stag
terragrunt apply --all --auto-approve

# Deploy production environment
cd ../prod
terragrunt apply --all --auto-approve
```

### 3. Configure kubectl

```bash
aws eks update-kubeconfig --name webapp-cluster --region us-east-1
```

### 4. Install AWS Load Balancer Controller

```bash
# Add Helm repo
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=webapp-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

### 5. Deploy Application

#### Option A: Via GitHub Actions (Automated)

```bash
# Set GitHub secrets
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# Deploy to staging
git checkout develop
git push origin develop

# Deploy to production
git checkout main
git merge develop
git push origin main
```

#### Option B: Manual Deployment

```bash
# Build and push Docker image
cd webapp
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com

docker build -t hello-world .
docker tag hello-world:latest $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/hello-world:latest
docker push $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/hello-world:latest

# Deploy to Kubernetes
cd k8s/overlays/staging
kubectl apply -k .
```

### 6. Verify Deployment

```bash
# Check pods
kubectl get pods -n hello-world-staging

# Test application
kubectl port-forward -n hello-world-staging service/hello-world-service 8080:80
curl http://localhost:8080/health
```

### 7. Access via Load Balancer

```bash
# Get ALB URL
kubectl get ingress -A

# Test endpoints
curl http://<alb-dns>/
curl http://<alb-dns>/health
```

## Environment Management

### Staging
- Namespace: `hello-world-staging`
- Resources: Minimal (t3.small nodes)
- Auto-scaling: 1-5 nodes

### Production
- Namespace: `hello-world-production`
- Resources: Standard (t3.medium nodes)
- Auto-scaling: 2-10 nodes

## Monitoring

```bash
# View logs
kubectl logs -f -l app=hello-world -n hello-world-staging

# Check metrics
kubectl top pods -n hello-world-staging
kubectl get hpa -n hello-world-staging

# CloudWatch
# AWS Console > CloudWatch > Container Insights
```

## Troubleshooting

```bash
# Debug pods
kubectl describe pod <pod-name> -n hello-world-staging
kubectl exec -it <pod-name> -n hello-world-staging -- sh

# Check events
kubectl get events -n hello-world-staging --sort-by='.lastTimestamp'

# Verify ECR images
aws ecr describe-images --repository-name hello-world --region us-east-1
```

## Clean Up

```bash
# Remove application
kubectl delete namespace hello-world-staging
kubectl delete namespace hello-world-production

# Destroy infrastructure
cd terraform/environments/stag
terragrunt run-all destroy --auto-approve

cd ../prod
terragrunt run-all destroy --auto-approve

# Delete ECR repository
aws ecr delete-repository --repository-name hello-world --force

# Delete S3 bucket and DynamoDB table
aws s3 rb s3://<your-bucket> --force
aws dynamodb delete-table --table-name terraform-state-lock
```

## CI/CD Workflow

1. **Feature Development**: Create feature branch → Push code
2. **Staging**: Merge to `develop` → Auto-deploy to staging
3. **Production**: Merge to `main` → Auto-deploy to production

