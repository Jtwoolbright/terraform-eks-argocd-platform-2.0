#!/bin/bash
set -e

echo "=========================================="
echo "Complete Kubernetes Cleanup Before Terraform Destroy"
echo "=========================================="
echo ""

# Configure kube ctl
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster

# Check if kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
  echo "❌ kubectl is not configured or cluster is already gone"
  echo ""
  echo "If cluster is already destroyed, you need to manually clean up AWS resources:"
  echo "1. Go to AWS Console → EC2 → Load Balancers"
  echo "2. Delete all load balancers with tags containing your cluster name"
  echo "3. Go to EC2 → Target Groups → Delete orphaned target groups"
  echo "4. Go to EC2 → Security Groups → Delete K8s-created security groups"
  exit 1
fi

echo "Step 1: Delete ArgoCD Ingress"
echo "--------------------------------------"
kubectl delete ingress argocd -n argocd --ignore-not-found=true

echo "Waiting for ArgoCD Ingress to be deleted..."
sleep 30

echo "✅ ArgoCD Ingress deleted"
echo ""

echo "Step 2: Check for remaining Ingress resources"
echo "--------------------------------------"
REMAINING_INGRESS=$(kubectl get ingress --all-namespaces -o json | jq -r '.items[].metadata.name' 2>/dev/null)

if [ -n "$REMAINING_INGRESS" ]; then
  echo "⚠️  Found remaining Ingress resources:"
  kubectl get ingress --all-namespaces
  echo ""
  read -p "Delete all Ingress resources? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl get ingress --all-namespaces -o json | jq -r '.items[] | "\(.metadata.namespace) \(.metadata.name)"' | while read ns name; do
      kubectl delete ingress $name -n $ns
    done
    echo "Waiting for ALBs to be cleaned up..."
    sleep 60
  fi
fi

echo "✅ No Ingress resources remain"
echo ""

echo "Step 3: Check for remaining LoadBalancer services"
echo "--------------------------------------"
REMAINING_LB=$(kubectl get svc --all-namespaces -o json | jq -r '.items[] | select(.spec.type=="LoadBalancer") | "\(.metadata.namespace)/\(.metadata.name)"')

if [ -n "$REMAINING_LB" ]; then
  echo "⚠️  Found LoadBalancer services:"
  echo "$REMAINING_LB"
  echo ""
  read -p "Convert all to ClusterIP? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl get svc --all-namespaces -o json | jq -r '.items[] | select(.spec.type=="LoadBalancer") | "\(.metadata.namespace) \(.metadata.name)"' | while read ns name; do
      kubectl patch svc $name -n $ns -p '{"spec": {"type": "ClusterIP"}}'
    done
    echo "Waiting for LoadBalancers to be removed..."
    sleep 60
  fi
fi

echo "✅ No LoadBalancer services remain"
echo ""

echo "Step 4: Wait for AWS resources to be cleaned up"
echo "--------------------------------------"
echo "Waiting 60 seconds for AWS to complete cleanup..."
sleep 60

echo ""
echo "Step 5: Verify AWS cleanup"
echo "--------------------------------------"
echo "Checking for ALBs created by the cluster..."
ALB_COUNT=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?contains(LoadBalancerName, 'k8s')].LoadBalancerName" --output text 2>/dev/null | wc -w)

if [ "$ALB_COUNT" -gt 0 ]; then
  echo "⚠️  Warning: $ALB_COUNT ALB(s) still exist"
  aws elbv2 describe-load-balancers --query "LoadBalancers[?contains(LoadBalancerName, 'k8s')].[LoadBalancerName,State.Code]" --output table
  echo ""
  echo "Waiting additional 60 seconds..."
  sleep 60
else
  echo "✅ No Kubernetes-created ALBs found"
fi

echo ""
echo "Step 6: Delete ArgoCD"

kubectl delete namespace argocd --ignore-not-found=true
echo "✅ ArgoCD deleted"


echo ""
echo "=========================================="
echo "✅ Kubernetes Cleanup Complete!"
echo "=========================================="
echo ""
echo "You can now safely run:"
echo "  terraform destroy"
echo ""