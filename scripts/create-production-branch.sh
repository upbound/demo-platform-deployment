#!/bin/bash

# Script to create and push the production branch
# This should be run once during initial setup

set -e

echo "=========================================="
echo "Creating Production Branch"
echo "=========================================="
echo ""

# Check if we're in a git repository
if [ ! -d .git ]; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Get current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)
echo "Current branch: $current_branch"

# Ensure we're on main and it's up to date
echo ""
echo "Checking out main branch..."
git checkout main
git pull origin main

# Check if production branch already exists locally
if git show-ref --verify --quiet refs/heads/production; then
    echo ""
    echo "Warning: production branch already exists locally"
    read -p "Do you want to recreate it? This will delete the local branch. (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git branch -D production
    else
        echo "Exiting without changes"
        exit 0
    fi
fi

# Check if production branch exists on remote
if git ls-remote --exit-code --heads origin production > /dev/null 2>&1; then
    echo ""
    echo "Warning: production branch already exists on remote"
    read -p "Do you want to fetch and checkout the existing branch? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        git checkout production
        git pull origin production
        echo ""
        echo "✓ Checked out existing production branch"
        exit 0
    else
        echo "Exiting without changes"
        exit 0
    fi
fi

# Create production branch from main
echo ""
echo "Creating production branch from main..."
git checkout -b production

# Update kustomization.yaml for production settings
echo ""
echo "Updating configuration for production environment..."
cat > kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: demo-app

resources:
- base

namePrefix: prod-

labels:
- pairs:
    environment: production

replicas:
- name: demo-app
  count: 3
EOF

# Update ArgoCD application for production
cat > argocd/application.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: demo-platform-prod
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/upbound/demo-platform-deployment
    targetRevision: production
    path: .
  destination:
    server: https://kubernetes.default.svc
    namespace: demo-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF

git add kustomization.yaml argocd/application.yaml
git commit -m "Update configuration for production environment"

echo ""
echo "Branch created successfully!"
echo ""
echo "Review the changes:"
git log --oneline -2

echo ""
read -p "Push production branch to remote? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "Pushing production branch to origin..."
    git push -u origin production
    echo ""
    echo "✓ Production branch created and pushed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Apply ArgoCD application for production: kubectl apply -f argocd/prod-application.yaml"
    echo "2. Verify ArgoCD is syncing: argocd app get demo-platform-prod"
    echo "3. Set up branch protection rules on GitHub"
else
    echo ""
    echo "Branch created locally but not pushed."
    echo "To push later, run: git push -u origin production"
fi

echo ""
echo "✓ Done!"
