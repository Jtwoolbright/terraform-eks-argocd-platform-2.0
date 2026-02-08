#!/bin/bash
set -e
set -x

echo "=== Installing AWS Load Balancer Controller ==="


# Get Params from Parameter store
CLUSTER_NAME=$(aws ssm get-parameter --name "/eks_project/cluster_name" --query 'Parameter.Value' --output text)
LB_ROLE_ARN=$(aws ssm get-parameter --name "/eks_project/lb_controller_role_arn" --query 'Parameter.Value' --output text)
VPC_ID=$(aws ssm get-parameter --name "/eks_project/vpc_id" --query 'Parameter.Value' --output text)

echo "Cluster: $CLUSTER_NAME"
echo "IAM Role: $LB_ROLE_ARN"
echo "VPC ID: $VPC_ID"

# Add EKS Helm repository
echo "Adding EKS Helm repository..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install AWS Load Balancer Controller
echo "Installing AWS Load Balancer Controller..."
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=$LB_ROLE_ARN \
  --set region=us-east-1 \
  --set vpcId=$VPC_ID 
  
  

echo ""
echo "⏳ Waiting for controller to be ready..."
kubectl wait --for=condition=available --timeout=300s \
  deployment/aws-load-balancer-controller -n kube-system

echo ""
echo "✅ AWS Load Balancer Controller installed successfully!"
echo ""
echo "Verify installation:"
echo "  kubectl get deployment -n kube-system aws-load-balancer-controller"