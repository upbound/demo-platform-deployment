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

# Validate dev environment
echo "1. Validating dev environment..."
if kubectl kustomize environments/dev > /tmp/dev-manifests.yaml; then
    echo "   ✓ Dev kustomization build successful"
    
    # Count resources
    resource_count=$(grep -c "^kind:" /tmp/dev-manifests.yaml || true)
    echo "   ✓ Generated $resource_count resources"
    
    # Check for basic required resources
    if grep -q "kind: Namespace" /tmp/dev-manifests.yaml && \
       grep -q "kind: Deployment" /tmp/dev-manifests.yaml && \
       grep -q "kind: Service" /tmp/dev-manifests.yaml; then
        echo "   ✓ Required resources present (Namespace, Deployment, Service)"
    else
        echo "   ⚠ Warning: Some required resources may be missing"
    fi
else
    echo "   ✗ Dev kustomization build failed"
    exit 1
fi

echo ""

# Validate prod environment
echo "2. Validating prod environment..."
if kubectl kustomize environments/prod > /tmp/prod-manifests.yaml; then
    echo "   ✓ Prod kustomization build successful"
    
    # Count resources
    resource_count=$(grep -c "^kind:" /tmp/prod-manifests.yaml || true)
    echo "   ✓ Generated $resource_count resources"
    
    # Check for basic required resources
    if grep -q "kind: Namespace" /tmp/prod-manifests.yaml && \
       grep -q "kind: Deployment" /tmp/prod-manifests.yaml && \
       grep -q "kind: Service" /tmp/prod-manifests.yaml; then
        echo "   ✓ Required resources present (Namespace, Deployment, Service)"
    else
        echo "   ⚠ Warning: Some required resources may be missing"
    fi
else
    echo "   ✗ Prod kustomization build failed"
    exit 1
fi

echo ""

# Check for common issues
echo "3. Checking for common issues..."

# Check for hardcoded secrets
if grep -r "password:" base/ environments/ 2>/dev/null || \
   grep -r "apiKey:" base/ environments/ 2>/dev/null || \
   grep -r "token:" base/ environments/ 2>/dev/null; then
    echo "   ⚠ Warning: Potential hardcoded secrets found!"
    echo "   Review your manifests and use Kubernetes Secrets or external secret managers"
else
    echo "   ✓ No obvious hardcoded secrets detected"
fi

# Check for image tags
if grep -r ":latest" base/ environments/ 2>/dev/null; then
    echo "   ⚠ Warning: Found ':latest' image tags"
    echo "   Consider using specific version tags for production"
else
    echo "   ✓ No ':latest' tags found"
fi

echo ""

# Show differences between environments
echo "4. Environment differences:"
echo ""
echo "   Dev environment:"
echo "   - $(grep -o "replicas: [0-9]*" /tmp/dev-manifests.yaml | head -1)"
echo "   - $(grep -o "namePrefix: .*" environments/dev/kustomization.yaml | head -1 || echo "namePrefix: dev-")"
echo ""
echo "   Prod environment:"
echo "   - $(grep -o "replicas: [0-9]*" /tmp/prod-manifests.yaml | head -1)"
echo "   - $(grep -o "namePrefix: .*" environments/prod/kustomization.yaml | head -1 || echo "namePrefix: prod-")"

echo ""
echo "=========================================="
echo "✓ Validation complete!"
echo "=========================================="
echo ""
echo "To view generated manifests:"
echo "  Dev:  cat /tmp/dev-manifests.yaml"
echo "  Prod: cat /tmp/prod-manifests.yaml"
echo ""
echo "To test deployment (dry-run, requires cluster access):"
echo "  kubectl apply --dry-run=client -f /tmp/dev-manifests.yaml"
echo "  kubectl apply --dry-run=client -f /tmp/prod-manifests.yaml"
