# demo-platform-deployment

GitOps deployment repository for Demo Platform, managed by ArgoCD.

## Overview

This repository contains Kubernetes manifests for deploying the Demo Platform to multiple environments using a GitOps workflow with ArgoCD.

## Repository Structure

```
.
├── argocd/                    # ArgoCD Application definitions
│   ├── dev-application.yaml   # Dev cluster application
│   └── prod-application.yaml  # Production cluster application
├── base/                      # Base Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── namespace.yaml
│   └── kustomization.yaml
├── environments/              # Environment-specific overlays
│   ├── dev/                   # Development environment
│   │   └── kustomization.yaml
│   └── prod/                  # Production environment
│       └── kustomization.yaml
└── scripts/                   # Utility scripts
    ├── create-production-branch.sh
    └── validate-manifests.sh
```

## GitOps Workflow

### Branch Strategy

- **`main` branch**: Watched by ArgoCD for deployment to the **dev cluster**
- **`production` branch**: Watched by ArgoCD for deployment to the **production cluster**

### Deployment Flow

1. Make changes to manifests in the appropriate environment directory
2. Commit and push to the `main` branch for dev changes
3. ArgoCD automatically syncs changes to the dev cluster
4. After validation in dev, merge/cherry-pick changes to the `production` branch
5. ArgoCD automatically syncs changes to the production cluster

## Getting Started

### Prerequisites

- kubectl installed and configured
- Access to the target Kubernetes clusters
- ArgoCD installed in the clusters

### Setting up ArgoCD Applications

Apply the ArgoCD application definitions to your ArgoCD instance:

```bash
# For dev environment
kubectl apply -f argocd/dev-application.yaml -n argocd

# For production environment
kubectl apply -f argocd/prod-application.yaml -n argocd
```

### Creating the Production Branch

Use the provided script to create the production branch:

```bash
./scripts/create-production-branch.sh
```

This will create and optionally push the production branch from main.

### Testing Manifests Locally

You can test the manifests locally using kustomize:

```bash
# Use the validation script (recommended)
./scripts/validate-manifests.sh

# Or manually test environments
kubectl kustomize environments/dev
kubectl kustomize environments/prod

# Apply to a cluster (for testing)
kubectl apply -k environments/dev
```

## Making Changes

### Development Environment Changes

1. Create a feature branch from `main`
2. Make your changes to files in `base/` or `environments/dev/`
3. Test locally with `kubectl kustomize environments/dev`
4. Commit and push your changes
5. Create a pull request to `main`
6. Once merged, ArgoCD will automatically sync to dev cluster

### Production Environment Changes

1. After changes are validated in dev, create a PR from `main` to `production`
2. Review and merge the PR
3. ArgoCD will automatically sync to production cluster

## Environment Configuration

### Development
- Location: `environments/dev/`
- Replicas: 1
- Name prefix: `dev-`
- Labels: `environment: dev`

### Production
- Location: `environments/prod/`
- Replicas: 3
- Name prefix: `prod-`
- Labels: `environment: production`

## ArgoCD Configuration

Both environments are configured with:
- **Auto-sync**: Enabled
- **Self-heal**: Enabled
- **Prune**: Enabled (removes resources deleted from Git)

See the [argocd/README.md](argocd/README.md) for more details.
