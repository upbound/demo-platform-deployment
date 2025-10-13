# Development Environment

This directory contains Kubernetes manifests for the development cluster.

## ArgoCD Configuration

ArgoCD should be configured to watch the `main` branch and sync these manifests to the dev cluster.

## Deploy

```bash
kubectl apply -k .
```
