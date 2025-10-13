# Quick Reference Guide

Quick commands and references for working with this GitOps repository.

## Common Commands

### Validate Manifests

```bash
# Validate current branch
kubectl kustomize .

# Use validation script
./scripts/validate-manifests.sh

# Save to file
kubectl kustomize . > manifests.yaml
```

### Test Before Committing

```bash
# Dry-run validation (requires cluster access)
kubectl kustomize . | kubectl apply --dry-run=client -f -

# Check YAML syntax
kubectl kustomize . | yamllint -

# View specific resource
kubectl kustomize . | grep -A 20 "kind: Deployment"
```

### ArgoCD Operations

```bash
# List applications
kubectl get applications -n argocd

# Get application status
argocd app get demo-platform-dev

# Sync manually
argocd app sync demo-platform-dev

# Sync with prune
argocd app sync demo-platform-dev --prune

# View logs
argocd app logs demo-platform-dev

# Rollback to previous version
argocd app rollback demo-platform-dev
```

### Git Operations

```bash
# Update from remote
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/my-feature

# Stage and commit
git add .
git commit -m "Descriptive message"

# Push to remote
git push origin feature/my-feature

# Merge main into your branch
git checkout feature/my-feature
git merge main
```

## File Locations

| What | Where |
|------|-------|
| Base manifests | `base/` |
| Environment config | `kustomization.yaml` (differs per branch) |
| ArgoCD apps | `argocd/` |
| Setup guide | `SETUP.md` |
| Contributing guide | `CONTRIBUTING.md` |

## Directory Structure

```
.
├── argocd/                      # ArgoCD Application definitions
│   ├── dev-application.yaml     # Dev cluster app
│   └── prod-application.yaml    # Prod cluster app
├── base/                        # Base Kubernetes resources
│   ├── deployment.yaml          # Application deployment
│   ├── service.yaml             # Application service
│   ├── namespace.yaml           # Namespace definition
│   └── kustomization.yaml       # Base kustomization
├── kustomization.yaml           # Environment overlay (differs per branch)
└── scripts/                     # Utility scripts
    ├── validate-manifests.sh
    └── create-production-branch.sh
```

## Kustomize Configuration

### Set Replicas

```yaml
# In kustomization.yaml
replicas:
- name: demo-app
  count: 1  # for dev, 3 for prod
```

### Set Image

```yaml
# In kustomization.yaml
images:
- name: nginx
  newName: nginx
  newTag: 1.22
```

### Apply Labels

```yaml
# In kustomization.yaml
labels:
- pairs:
    environment: dev
```

### Set Name Prefix

```yaml
# In kustomization.yaml
namePrefix: dev-  # or prod- for production
```

## Environment Variables

### Add ConfigMap

```bash
# Add to base/kustomization.yaml
configMapGenerator:
- name: app-config
  literals:
  - APP_ENV=production
  - LOG_LEVEL=info
```

### Reference in Deployment

```yaml
# In base/deployment.yaml
env:
- name: APP_ENV
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: APP_ENV
```

## Labels and Selectors

### Common Labels

```yaml
labels:
  app: demo-app
  environment: dev
  version: v1.0.0
  managed-by: argocd
```

### Label Transformers

```yaml
# In kustomization.yaml
labels:
- pairs:
    team: platform
    cost-center: engineering
```

## Troubleshooting

### ArgoCD Not Syncing

```bash
# Check application status
kubectl describe application demo-platform-dev -n argocd

# Check controller logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller --tail=100

# Force refresh
argocd app get demo-platform-dev --refresh
```

### Kustomize Errors

```bash
# Validate kustomization file
kubectl kustomize environments/dev --enable-alpha-plugins

# Check for common issues
kustomize cfg tree base/
```

### Deployment Issues

```bash
# Check pod status
kubectl get pods -n demo-app

# View pod logs
kubectl logs -n demo-app -l app=demo-app

# Describe deployment
kubectl describe deployment -n demo-app

# Check events
kubectl get events -n demo-app --sort-by='.lastTimestamp'
```

## Branch Strategy

| Branch | Purpose | ArgoCD Target |
|--------|---------|---------------|
| `main` | Development releases | Dev cluster |
| `production` | Production releases | Prod cluster |
| `feature/*` | Feature development | Not watched |
| `hotfix/*` | Emergency fixes | Not watched |

## Promotion Workflow

```
feature/my-feature → main → production
     ↓                ↓          ↓
  (local)         (dev)      (prod)
```

## Quick Links

- [Setup Guide](SETUP.md)
- [Contributing Guide](CONTRIBUTING.md)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kustomize Documentation](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## Getting Help

1. Check existing documentation in this repo
2. Review ArgoCD application status and logs
3. Test manifests locally with `kubectl kustomize`
4. Check GitHub Actions workflow results
5. Create an issue with details and error messages
