# demo-platform-deployment

GitOps deployment repository for Demo Platform, managed by ArgoCD.

## Overview

This repository contains Kubernetes manifests for deploying the Demo Platform to multiple environments using a GitOps workflow with ArgoCD.

## Repository Structure

```
.
├── argocd/                    # ArgoCD Application definition
│   └── application.yaml       # ArgoCD application for this branch
├── base/                      # Base Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── namespace.yaml
│   └── kustomization.yaml
├── kustomization.yaml         # Environment-specific overlay (differs per branch)
└── scripts/                   # Utility scripts
    ├── create-production-branch.sh
    └── validate-manifests.sh
```

**Note:** The `kustomization.yaml` file at the root differs between branches:
- `main` branch: Configured for dev (1 replica, `dev-` prefix)
- `production` branch: Configured for production (3 replicas, `prod-` prefix)

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

Apply the ArgoCD application definition to your ArgoCD instance:

```bash
# For dev environment (from main branch)
kubectl apply -f argocd/application.yaml -n argocd

# For production environment (after creating production branch)
git checkout production
kubectl apply -f argocd/application.yaml -n argocd
```

**Note:** Each branch contains only its own ArgoCD application definition.

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

# Or manually test the current branch
kubectl kustomize .

# Apply to a cluster (for testing)
kubectl apply -k .
```

## Making Changes

### Development Environment Changes

1. Create a feature branch from `main`
2. Make your changes to files in `base/` or `kustomization.yaml`
3. Test locally with `./scripts/validate-manifests.sh`
4. Commit and push your changes
5. Create a pull request to `main`
6. Once merged, ArgoCD will automatically sync to dev cluster

### Production Environment Changes

1. After changes are validated in dev, create a PR from `main` to `production`
2. Review and merge the PR (the `kustomization.yaml` differs between branches)
3. ArgoCD will automatically sync to production cluster

## Environment Configuration

### Development (`main` branch)
- Replicas: 1
- Name prefix: `dev-`
- Labels: `environment: dev`

### Production (`production` branch)
- Replicas: 3
- Name prefix: `prod-`
- Labels: `environment: production`

## ArgoCD Configuration

Both environments are configured with:
- **Auto-sync**: Enabled
- **Self-heal**: Enabled
- **Prune**: Enabled (removes resources deleted from Git)

See the [argocd/README.md](argocd/README.md) for more details.
