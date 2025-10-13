# GitOps Repository Setup Guide

This guide walks you through setting up the GitOps repository for ArgoCD deployment.

## Initial Setup

### 1. Create the Production Branch

After the initial repository structure is set up on the `main` branch, create the `production` branch:

```bash
# From the main branch
git checkout main
git pull origin main

# Create and push the production branch
git checkout -b production
git push -u origin production
```

The `production` branch should mirror the `main` branch initially. Future production releases will be deployed by merging or cherry-picking changes from `main` to `production`.

### 2. Configure ArgoCD Applications

Apply the ArgoCD application definitions to your ArgoCD instance(s):

#### For Development Cluster

```bash
kubectl apply -f argocd/dev-application.yaml -n argocd
```

This application will:
- Watch the `main` branch
- Deploy manifests from the repository root
- Automatically sync changes

#### For Production Cluster

```bash
kubectl apply -f argocd/prod-application.yaml -n argocd
```

This application will:
- Watch the `production` branch
- Deploy manifests from the repository root
- Automatically sync changes

### 3. Update ArgoCD Application Configuration (if needed)

If you're using external clusters, update the `destination.server` field in the ArgoCD application files:

```yaml
destination:
  server: https://your-cluster-endpoint
  namespace: demo-app
```

Or use cluster name:

```yaml
destination:
  name: your-cluster-name
  namespace: demo-app
```

## Branch Protection (Recommended)

### Main Branch
Protect the `main` branch with:
- Require pull request reviews
- Require status checks to pass
- Include administrators in restrictions (optional)

### Production Branch
Protect the `production` branch with:
- Require pull request reviews (at least 2 reviewers recommended)
- Require status checks to pass
- Include administrators in restrictions

## Workflow

### Deploying to Development

1. Create a feature branch from `main`
2. Make changes to `base/` or `kustomization.yaml`
3. Test locally: `./scripts/validate-manifests.sh`
4. Create PR to `main`
5. After merge, ArgoCD syncs to dev cluster automatically

### Promoting to Production

1. After validating changes in dev, create PR from `main` to `production`
2. Review changes carefully
3. Merge PR to `production`
4. ArgoCD syncs to production cluster automatically

### Emergency Hotfix

1. Create hotfix branch from `production`
2. Make minimal changes
3. Create PR to `production`
4. After production deployment, backport to `main`

## Verification

### Check ArgoCD Application Status

```bash
# List applications
kubectl get applications -n argocd

# Check application details
kubectl get application demo-platform-dev -n argocd -o yaml
kubectl get application demo-platform-prod -n argocd -o yaml
```

### Check Deployed Resources

```bash
# Dev cluster
kubectl get all -n demo-app

# Look for dev-prefixed resources
kubectl get deployments -n demo-app -l environment=dev

# Prod cluster
kubectl get deployments -n demo-app -l environment=production
```

## Troubleshooting

### ArgoCD Not Syncing

1. Check application status: `kubectl get application -n argocd`
2. Check application details: `argocd app get demo-platform-dev`
3. Force sync: `argocd app sync demo-platform-dev`

### Kustomize Build Errors

Test locally before committing:

```bash
# Test current branch
kubectl kustomize .

# Or use validation script
./scripts/validate-manifests.sh
```

### Check ArgoCD Logs

```bash
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
```

## Best Practices

1. **Always test kustomize builds locally** before committing
2. **Use descriptive commit messages** (ArgoCD shows these in the UI)
3. **Keep base/ minimal** - put environment-specific config in overlays
4. **Review production PRs carefully** - use checklists
5. **Monitor ArgoCD dashboard** after merges
6. **Keep sync policies consistent** across environments
7. **Use semantic versioning** for image tags (avoid `latest`)

## Next Steps

1. Customize the base manifests for your application
2. Add additional overlays for more environments (staging, qa, etc.)
3. Implement CI/CD pipelines to update image tags automatically
4. Set up notifications for ArgoCD sync events
5. Add more sophisticated kustomize patches for environment differences
