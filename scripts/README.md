# Utility Scripts

This directory contains utility scripts for managing the GitOps repository.

## Available Scripts

### create-production-branch.sh

Creates the production branch from main and optionally pushes it to the remote repository.

**Usage:**
```bash
./scripts/create-production-branch.sh
```

**What it does:**
- Checks if you're in a git repository
- Switches to main branch and pulls latest changes
- Creates production branch from main
- Updates `kustomization.yaml` with production settings (3 replicas, prod- prefix)
- Optionally pushes to remote
- Provides next steps for ArgoCD setup

**When to use:**
- During initial repository setup
- When production branch needs to be recreated

### validate-manifests.sh

Validates Kubernetes manifests for all environments.

**Usage:**
```bash
./scripts/validate-manifests.sh
```

**What it does:**
- Validates kustomization on current branch
- Checks for common issues (hardcoded secrets, latest tags)
- Shows configuration details (replicas, etc.)
- Generates manifest files in /tmp for review

**When to use:**
- Before committing changes
- During pull request reviews
- To debug kustomization issues

## Requirements

Both scripts require:
- `git` command-line tool
- `kubectl` command-line tool (for validate-manifests.sh)

## Making Scripts Executable

If scripts are not executable, run:

```bash
chmod +x scripts/*.sh
```

## Adding New Scripts

When adding new scripts:
1. Place them in this directory
2. Make them executable: `chmod +x scripts/your-script.sh`
3. Add documentation to this README
4. Follow bash best practices:
   - Use `set -e` to exit on errors
   - Add clear echo statements for user feedback
   - Check for required tools before running
   - Provide helpful error messages
