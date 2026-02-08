#!/bin/bash
set -e

echo "=== Installing ArgoCD ==="

# Create namespace
echo "Creating argocd namespace..."
kubectl create namespace argocd

# Install ArgoCD
echo "Installing ArgoCD components..."
kubectl apply -n argocd --server-side=true -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD pods to be ready (this may take 2-3 minutes)..."
kubectl wait --for=condition=available --timeout=300s \
  deployment/argocd-server \
  deployment/argocd-repo-server \
  deployment/argocd-applicationset-controller \
  -n argocd

echo ""
echo "✅ ArgoCD installed successfully!"