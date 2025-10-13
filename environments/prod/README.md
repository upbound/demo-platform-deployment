# Production Environment

This directory contains Kubernetes manifests for the production cluster.

## ArgoCD Configuration

ArgoCD should be configured to watch the `production` branch and sync these manifests to the production cluster.

## Deploy

```bash
kubectl apply -k .
```
