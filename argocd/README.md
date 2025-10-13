# ArgoCD Application Definition

This directory contains the ArgoCD Application manifest for this environment.

## Application

### Development Environment (`application.yaml`)
- Watches `main` branch
- Deploys to dev cluster
- Path: `.` (repository root)

**Note:** The `production` branch contains its own `application.yaml` configured for the production environment.

## Installation

Apply this manifest to your ArgoCD instance:

```bash
kubectl apply -f application.yaml -n argocd
```

## Configuration

Update the `destination.server` field in the application to point to your actual cluster endpoint if using an external cluster.

## Branch-Based Approach

Each branch contains only its relevant ArgoCD application definition:
- `main` branch: Contains development application
- `production` branch: Contains production application

This keeps the configuration consistent with the branch-based environment separation strategy.
