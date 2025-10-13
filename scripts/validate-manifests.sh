#!/bin/bash

# Script to validate Kubernetes manifests locally
# Run this before committing changes

set -e

echo "=========================================="
echo "Validating Kubernetes Manifests"
echo "=========================================="
echo ""

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed"
    echo "Please install kubectl: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

# Get current branch
current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
echo "Current branch: $current_branch"
echo ""

# Validate current branch
echo "1. Validating manifests on current branch..."
if kubectl kustomize . > /tmp/manifests.yaml; then
    echo "   ✓ Kustomization build successful"
    
    # Count resources
    resource_count=$(grep -c "^kind:" /tmp/manifests.yaml || true)
    echo "   ✓ Generated $resource_count resources"
    
    # Check for basic required resources
    if grep -q "kind: Namespace" /tmp/manifests.yaml && \
       grep -q "kind: Deployment" /tmp/manifests.yaml && \
       grep -q "kind: Service" /tmp/manifests.yaml; then
        echo "   ✓ Required resources present (Namespace, Deployment, Service)"
    else
        echo "   ⚠ Warning: Some required resources may be missing"
    fi
    
    # Show replica count
    replica_count=$(grep -o "replicas: [0-9]*" /tmp/manifests.yaml | head -1 || echo "replicas: not specified")
    echo "   ✓ $replica_count"
else
    echo "   ✗ Kustomization build failed"
    exit 1
fi

echo ""

# Check for common issues
echo "2. Checking for common issues..."

# Check for hardcoded secrets
if grep -r "password:" base/ 2>/dev/null || \
   grep -r "apiKey:" base/ 2>/dev/null || \
   grep -r "token:" base/ 2>/dev/null; then
    echo "   ⚠ Warning: Potential hardcoded secrets found!"
    echo "   Review your manifests and use Kubernetes Secrets or external secret managers"
else
    echo "   ✓ No obvious hardcoded secrets detected"
fi

# Check for image tags
if grep -r ":latest" base/ 2>/dev/null; then
    echo "   ⚠ Warning: Found ':latest' image tags"
    echo "   Consider using specific version tags for production"
else
    echo "   ✓ No ':latest' tags found"
fi

echo ""
echo "=========================================="
echo "✓ Validation complete!"
echo "=========================================="
echo ""
echo "To view generated manifests:"
echo "  cat /tmp/manifests.yaml"
echo ""
echo "To test deployment (dry-run, requires cluster access):"
echo "  kubectl apply --dry-run=client -f /tmp/manifests.yaml"
echo ""
echo "Note: Different branches (main, production) contain different"
echo "configurations. Validate on each branch separately."
