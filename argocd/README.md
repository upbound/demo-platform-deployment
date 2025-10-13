# ArgoCD Application Definitions

This directory contains ArgoCD Application manifests for deploying to different environments.

## Applications

### Development (`dev-application.yaml`)
- Watches `main` branch
- Deploys to dev cluster
- Path: `environments/dev`

### Production (`prod-application.yaml`)
- Watches `production` branch
- Deploys to production cluster
- Path: `environments/prod`

## Installation

Apply these manifests to your ArgoCD instance:

```bash
kubectl apply -f dev-application.yaml -n argocd
kubectl apply -f prod-application.yaml -n argocd
```

## Configuration

Update the `destination.server` field in each application to point to your actual cluster endpoints if using external clusters.
