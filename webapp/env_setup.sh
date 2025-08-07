# Create IAM policy for GitHub Actions
cat > github-actions-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:CreateRepository",
                "ecr:DescribeRepositories"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster",
                "eks:ListClusters"
            ],
            "Resource": "*"
        }
    ]
}
EOF

# Create the policy
aws iam create-policy \
    --policy-name GitHubActionsEKSDeployPolicy \
    --policy-document file://github-actions-policy.json

# Create IAM user
aws iam create-user --user-name github-actions-deploy

# Attach policies
aws iam attach-user-policy \
    --user-name github-actions-deploy \
    --policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/GitHubActionsEKSDeployPolicy

aws iam attach-user-policy \
    --user-name github-actions-deploy \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

# Create access keys
aws iam create-access-key --user-name github-actions-deploy > github-access-keys.json

# Display the keys (save these securely!)
echo "AWS_ACCESS_KEY_ID: $(cat github-access-keys.json | jq -r .AccessKey.AccessKeyId)"
echo "AWS_SECRET_ACCESS_KEY: $(cat github-access-keys.json | jq -r .AccessKey.SecretAccessKey)"