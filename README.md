# Terraform EKS ArgoCD Platform v2

Production-grade AWS EKS cluster deployment with ArgoCD GitOps, comprehensive observability, and automated scaling. Deploy and destroy entire Kubernetes infrastructure with a single PR comment.

## 🎯 Project Overview

A production-ready Kubernetes platform on AWS EKS demonstrating end-to-end platform engineering. Everything from VPC to monitoring is deployed as code with GitOps workflows, automated CI/CD, and comment-driven operations.

**Deploy entire infrastructure—cluster, monitoring, autoscaling, and applications—with a single PR comment: `/deploy all`**

## 🎬 Platform Demo

### ArgoCD App of Apps
![Image](https://github.com/user-attachments/assets/5b665663-3e38-4a9c-8121-8f1a57c870fb)
*GitOps dashboard showing hierarchical application management with platform, observability, and application layers*

### Grafana Observability
![Image](https://github.com/user-attachments/assets/67eb8841-4f38-4e44-8d2e-f92d5985a2b3)
*Real-time cluster metrics, node resources, and pod health monitoring*

## ✨ What's New in Version 2

**v2 brings enterprise-grade capabilities:**

- **📊 Observability**: Grafana + Prometheus stack for full cluster visibility
- **🏗️ Scalable GitOps**: App of Apps pattern manages platform and application deployments
- **🔐 Dynamic Secrets**: External Secrets Operator syncs from SSM Parameter Store
- **📈 Auto-scaling**: Cluster Autoscaler provisions nodes on demand
- **📦 Container Registry**: Terraform-managed ECR with lifecycle policies
- **🔗 Full Stack Demo**: Links to ai-portal app repo for complete platform showcase

### Version 1 → Version 2 Migration

| Feature | v1 | v2 |
|---------|----|----|
| ArgoCD Pattern | Single app deployments | App of Apps |
| Observability | None | Grafana + Prometheus |
| Secrets Management | SSM (hardcoded) | External Secrets Operator + SSM |
| Autoscaling | Manual node management | Cluster Autoscaler |
| Container Registry | External/manual | Terraform-managed ECR |
| Application Integration | Sample nginx only | Full ai-portal integration |

## ✨ Key Features

**Infrastructure Automation**
- Comment-driven deployments via GitHub PR comments (`/deploy`, `/plan`, `/destroy`)
- Multi-layer Terraform architecture (networking → ECR → EKS → apps)
- S3 remote state with native locking

**Platform Stack**
- EKS 1.31 with managed node groups and IRSA
- ArgoCD App of Apps for declarative application management
- kube-prometheus: Grafana, Prometheus, Alertmanager
- External Secrets Operator + SSM Parameter Store
- Cluster Autoscaler for dynamic node provisioning
- AWS Load Balancer Controller for ALB ingress
- Terraform-managed ECR repositories

## 🏗️ Architecture

### Infrastructure Layers

```
┌─────────────────────────────────────────────────────────┐
│                  Bootstrap Layer                         │
│  • S3 Bucket (Terraform state with native locking)     │
│  • OIDC Provider for GitHub Actions                     │
│  • IAM Role for GitHub Actions                          │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                     GitHub Actions                       │
│  (OIDC Authentication for AWS Access)                   │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                  Networking Layer                        │
│  • VPC with public/private subnets                      │
│  • NAT Gateways                                          │
│  • Internet Gateway                                      │
│  • Route Tables & Security Groups                       │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                    ECR Layer (NEW)                       │
│  • ECR Repositories for application images             │
│  • Lifecycle policies for image management             │
│  • IAM policies for push/pull access                   │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                    EKS Layer                             │
│  • EKS Cluster (1.31)                                   │
│  • Managed Node Group (t3.medium)                       │
│  • AWS Load Balancer Controller (IRSA)                 │
│  • IAM Roles & Policies                                 │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              Application Layer (Enhanced)                │
│  ┌─────────────────────────────────────────────┐       │
│  │         ArgoCD App of Apps Root             │       │
│  └──────┬──────────────┬───────────┬───────────┘       │
│         │              │           │                    │
│         ▼              ▼           ▼                    │
│  ┌──────────┐  ┌─────────────┐  ┌──────────────┐     │
│  │ Platform │  │ Observability│  │ Applications │     │
│  │   Apps   │  │    Stack     │  │              │     │
│  └──────────┘  └─────────────┘  └──────────────┘     │
│       │              │                   │             │
│       ▼              ▼                   ▼             │
│  • External     • Grafana          • ai-portal        │
│    Secrets      • Prometheus       • Custom apps      │
│    Operator     • Alertmanager                        │
│  • Cluster      • Node Exporter                       │
│    Autoscaler   • kube-state-metrics                  │
│  • ArgoCD                                             │
│    Ingress                                            │
└───────────────────────────────────────────────────────┘
```

### Technology Stack

| Component | Technology | Version/Details |
|-----------|-----------|-----------------|
| Infrastructure as Code | Terraform | 1.14.3+ |
| Container Orchestration | AWS EKS | 1.31 |
| GitOps | ArgoCD | Latest Stable (App of Apps) |
| Observability | kube-prometheus | Grafana, Prometheus, Alertmanager |
| Secrets Management | External Secrets Operator | SSM Parameter Store integration |
| Autoscaling | Cluster Autoscaler | AWS Auto Scaling Groups |
| Container Registry | Amazon ECR | Terraform-managed |
| CI/CD | GitHub Actions | OIDC-authenticated |
| Cloud Provider | AWS | - |
| State Backend | S3 | Native locking |
| Node Type | t3.medium | Managed node groups |

## 📋 Repository Structure

```
.
├── .github/
│   └── workflows/              # GitHub Actions workflow definitions
│       ├── deploy-all.yml
│       ├── deploy-layer.yml
│       ├── destroy-all.yml
│       ├── destroy-layer.yml
│       ├── plan.yml
│       └── help.yml
├── demos/                      # Demo GIFs and screenshots
│   ├── argocd-demo.gif
│   └── grafana-demo.gif
├── bootstrap/                  # Remote state & OIDC setup
│   ├── main.tf                # S3, OIDC provider
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
├── networking/                 # VPC, subnets, NAT gateways
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf
│   └── provider.tf
├── ecr/                        # NEW: Container registry layer
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf
│   └── provider.tf
├── eks/                        # EKS cluster and node groups
│   ├── main.tf
│   ├── data.tf                # Data sources for remote state
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf
│   └── provider.tf
└── application/                # ArgoCD apps & platform configuration
    ├── parent-app.yml          # App of Apps root
    ├── argocd-apps/            # ArgoCD Application CRDs
    │   ├── external-secrets-operator.yml
    │   ├── monitoring-app.yml
    │   ├── nginx-app.yml
    │   ├── ai-portal.yml
    │   └── cluster-autoscaler.yml
    ├── k8s-manifests/          # Kubernetes resource definitions
    │   ├── argocd/
    │   │   ├── argocd-configmap.yml
    │   │   └── argocd-ingress.yml
    │   ├── monitoring/
    │   │   ├── manifests/
    │   │   │   └── external-secrets.yml
    │   │   └── values.yml
    │   └── nginx/
    │       ├── demo-namespace.yml
    │       ├── nginx-deployment.yml
    │       ├── nginx-ingress.yml
    │       └── nginx-service.yml
    └── scripts/                # Installation & setup scripts
        ├── install-argocd.sh
        ├── install-lb-controller.sh
        ├── put-argo-password.sh
        ├── expose-argocd.sh
        └── cleanup.sh
```

## 🚀 Getting Started

### Prerequisites

- **AWS Account** with appropriate permissions
- **GitHub Repository** with Actions enabled
- **Application Repository** (e.g., ai-portal) for demonstrating full workflow
- **Local Tools** (for testing):
  - Terraform 1.14.3+
  - kubectl
  - AWS CLI
  - helm (for kube-prometheus)
- **SSL certificates** for ingress resources (or use cert-manager)

### Initial Setup

1. **Deploy Bootstrap Layer First** (Manual - one time setup)
   ```bash
   cd bootstrap
   terraform init
   terraform apply
   ```
   This creates:
   - S3 bucket for remote state storage with native locking
   - OIDC provider for GitHub Actions
   - IAM role for GitHub Actions to assume

2. **Configure Backend for Other Layers**
   - Update backend configuration in networking, ecr, eks, and application layers
   - Reference the S3 bucket from bootstrap outputs

3. **Set GitHub Secrets**
   - AWS account ID
   - OIDC role ARN (from bootstrap outputs)
   - Application repository credentials (for ai-portal integration)
   - Any required environment variables

4. **Prepare SSM Parameters**
   - Create SecureString parameters for applications that will use External Secrets Operator
   - Configure IAM policies for External Secrets Operator service account to access SSM

5. **Configure Application Repository Link**
   - Update ArgoCD application manifests to point to ai-portal repository
   - Ensure proper Git credentials are configured

### Deployment Workflow

The platform is deployed entirely through GitHub Actions via pull request comments:

#### 1. Plan Changes
```
/plan all              # Plan all layers
/plan <tf-layer>       # Plan specific layer (networking, ecr, eks)
```

#### 2. Deploy Infrastructure
```
/deploy all           # Deploy all layers sequentially
/deploy <layer>       # Deploy specific layer (networking, ecr, eks, argo)
```

The workflow will:
1. Run `terraform validate` and `terraform plan`
2. Post plan output to PR comments
3. Execute `terraform apply` upon approval

#### 3. Deploy Applications via ArgoCD
Once infrastructure is deployed, ArgoCD's App of Apps pattern automatically:
1. Deploys the root application
2. Root app creates child applications for:
   - Platform infrastructure (External Secrets, Cluster Autoscaler)
   - Observability stack (kube-prometheus, Grafana)
   - User applications (ai-portal and custom apps)

#### 4. Destroy Infrastructure
```
/destroy all          # Destroy all layers in reverse order
/destroy <layer>      # Destroy specific layer (networking, ecr, eks, argo)
```

#### 5. Get Help
```
/help                 # Display available commands
```

## 🔐 Security Features

- **OIDC Authentication**: GitHub Actions authenticates to AWS using OIDC (no long-lived credentials)
- **IRSA for Kubernetes Services**: Service accounts use IAM roles for AWS API access
  - AWS Load Balancer Controller
  - External Secrets Operator
  - Cluster Autoscaler
- **External Secrets Operator**: Application secrets fetched from SSM Parameter Store at runtime
- **Private Subnets**: EKS nodes run in private subnets with NAT gateway egress
- **Secrets Management**: Sensitive data stored in SSM SecureString parameters, not in Git
- **State Locking**: S3 native locking prevents concurrent Terraform operations
- **ECR Scanning**: Container images can be scanned for vulnerabilities
- **Network Policies**: Can be enforced for pod-to-pod communication

## 🔧 Technical Highlights

### App of Apps Pattern
ArgoCD's App of Apps provides hierarchical application management—one root app deploys platform infrastructure, observability tools, and user applications. Changes to any component trigger automatic GitOps sync. This pattern scales to hundreds of applications while maintaining clear separation between platform and app teams.

### External Secrets Operator
Rather than hardcoding secrets or storing them in Git, applications reference SSM parameters via ExternalSecret CRDs. The operator (using IRSA) fetches SecureString parameters and creates Kubernetes secrets automatically. Secrets rotate without redeploying applications.

### Observability with kube-prometheus
Full Prometheus stack deployed via ArgoCD provides cluster and application metrics. Grafana dashboards show node resources, pod health, autoscaler activity, and custom app metrics. Alertmanager handles notification routing.

### Cluster Autoscaler
Monitors for unschedulable pods and scales node groups accordingly. Integrated with EKS managed node groups via IRSA. Prevents over-provisioning by scaling down underutilized nodes while respecting pod disruption budgets.

### Multi-Layer Terraform
Infrastructure split into bootstrap (state + OIDC), networking (VPC), ECR (registries), EKS (cluster), and application (K8s manifests). Layers can be updated independently, reducing blast radius and enabling faster iteration on specific components.

## 💡 Key Learnings

**App of Apps Complexity**: Migrating to hierarchical GitOps required careful planning around sync waves and parent-child dependencies. Solution: clear layer separation (platform/observability/apps) with explicit sync ordering.

**IRSA Configuration**: Each AWS-integrated service account needs precise IAM trust policies. External Secrets Operator failure taught me to validate OIDC thumbprints and service account annotations before debugging application-level issues.

**Resource Planning**: kube-prometheus consumed more resources than expected on t3.medium nodes during initial deployment. Cluster Autoscaler solved this by provisioning additional nodes, but highlighted the importance of proper resource requests/limits and capacity planning.

**Multi-Repo Contracts**: Coordinating infrastructure and application repos requires clear API boundaries—infrastructure provides cluster/observability/ECR, applications provide manifests. Breaking this contract causes deployment failures.

## 🌐 Access Points

**ArgoCD**: Get URL from Terraform outputs. Password: `aws ssm get-parameter --name /eks-project/argocd-admin --with-decryption --query 'Parameter.Value' --output text`

**Grafana**: Get URL from ArgoCD or AWS console. Credentials stored in K8s secret: `kubectl get secret -n monitoring grafana-admin-credentials -o jsonpath='{.data.admin-password}' | base64 -d`

**ai-portal**: Deployed via ArgoCD, accessible through ALB ingress. Uses External Secrets for config, images from ECR.

## 🚧 Potential Enhancements

- cert-manager for automated SSL with Let's Encrypt
- Service mesh (Istio/Linkerd) for mTLS and advanced traffic management  
- OPA/Gatekeeper for policy enforcement
- Horizontal/Vertical Pod Autoscalers
- Velero for disaster recovery backups
- Multi-environment setup (dev/staging/prod)
- Cost monitoring with Kubecost
- Distributed tracing with Jaeger/Tempo

## 🛠️ Technologies Demonstrated

**Infrastructure as Code**
- Terraform resource provisioning
- Remote state management with locking
- Multi-layer architecture with dependencies
- Output variable sharing across layers
- ECR lifecycle policy management

**Kubernetes & Cloud Native**
- EKS cluster management
- Kubernetes Ingress with ALB
- IRSA/OIDC service account authentication
- App of Apps GitOps pattern
- Helm chart deployment
- Custom Resource Definitions (CRDs)

**Observability & Monitoring**
- Prometheus metric collection
- Grafana visualization
- Alertmanager configuration
- kube-state-metrics for cluster insights
- Node Exporter for host metrics

**Secrets & Security**
- External Secrets Operator
- AWS Secrets Manager integration
- IRSA for least-privilege access
- Network isolation with private subnets

**Autoscaling & Efficiency**
- Cluster Autoscaler for nodes
- Horizontal Pod Autoscaler (can be added)
- Resource requests/limits optimization

**CI/CD & Automation**
- GitHub Actions workflows
- OIDC authentication (no static credentials)
- Comment-driven operations
- Multi-repository coordination

**AWS Services**
- EKS (Elastic Kubernetes Service)
- VPC networking with NAT gateways
- Application Load Balancer
- ECR (Elastic Container Registry)
- SSM Parameter Store (SecureString)
- S3 (state backend with native locking)
- IAM (OIDC providers, roles, policies, IRSA)
- Auto Scaling Groups

**DevOps Practices**
- GitOps workflow
- Infrastructure as Code
- Declarative configuration
- Automated deployment pipelines
- Self-service infrastructure
- Observability-driven development

## 📝 Quick Start

1. **Bootstrap** (one-time): `cd bootstrap && terraform apply` - creates S3 state backend, OIDC provider, IAM role
2. **Deploy via PR comments**: 
   - `/plan all` - preview changes
   - `/deploy all` - deploy networking → ECR → EKS → applications
   - `/destroy all` - teardown in reverse order
3. **Access platforms**: URLs in Terraform outputs, passwords in SSM Parameter Store

---

**Built to showcase real-world engineering skills applicable to platform engineering, DevOps, and cloud infrastructure roles**


**AI-Portal Repo**: [https://github.com/Jtwoolbright/ai-infrastructure-self-service-portal]
**Version 1 Repo**: [https://github.com/Jtwoolbright/terraform-eks-argocd-platform]


📫 **Let's Connect:** [Blog](https://medium.com/@woolbright.josh.t) [LinkedIn](https://linkedin.com/in/josh-woolbright)