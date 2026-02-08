#!/bin/bash
set -e

echo "=== ArgoCD Login Information ==="
echo ""


ARGOCD_URL=$(kubectl get ingress argocd -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)

if [ -z "$ARGOCD_URL" ]; then
  echo "⚠️  ArgoCD Ingress URL not ready yet. Checking..."
  kubectl get ingress argocd -n argocd
  echo ""
  echo "Wait a few minutes for the ALB to be provisioned."
  exit 1
fi

echo "🌐 URL: https://$ARGOCD_URL/argo"
echo ""

ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

aws ssm put-parameter --name "/eks_project/argo-password" --value $ARGOCD_PASSWORD  --type "SecureString" --region us-east-1 --overwrite

if [ -z "$ARGOCD_PASSWORD" ]; then
  echo "❌ Could not retrieve password. Is ArgoCD installed?"
  exit 1
fi

echo "👤 Username: admin"
echo "🔑 Password: retrieve from ssm param /eks_project/argo-password"
echo ""
echo "Note: Use HTTPS for the URL above"