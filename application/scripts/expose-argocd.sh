#!/bin/bash
set -e

echo "=== Exposing ArgoCD via Ingress ==="

# Change service to ClusterIP (internal only)
echo "Converting ArgoCD service to ClusterIP..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "ClusterIP"}}'

# Apply ArgoCD ConfigMap
kubectl apply -f ../k8-manifests/argocd/argocd-configmap.yml

# Apply the Ingress
echo "Creating Ingress for ArgoCD..."
kubectl apply -f ../k8-manifests/argocd/argocd-ingress.yml

# Restart ArgoCD server to pick up ConfigMap changes
echo "Restarting ArgoCD server..."
kubectl rollout restart deployment argocd-server -n argocd

# Wait for rollout to complete
echo "Waiting for ArgoCD server to be ready..."
kubectl rollout status deployment argocd-server -n argocd

# Wait for Ingress to get an address
echo "Waiting for ALB to be provisioned (this may take 2-3 minutes)..."
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' ingress/argocd -n argocd --timeout=300s

echo ""
echo "🌐 ArgoCD UI is available at:https://"
kubectl get ingress argocd -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
echo ""