# Contributing to Demo Platform Deployment

This document provides guidelines for contributing to this GitOps repository.

## Prerequisites

Before contributing, ensure you have:

- `kubectl` installed
- Access to test the manifests locally
- Understanding of Kubernetes manifests
- Understanding of Kustomize

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout main
git pull origin main
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes

Edit the appropriate files:
- **Base resources**: Edit files in `base/`
- **Environment-specific config**: Edit `kustomization.yaml` (at repository root)
  - This file differs between `main` and `production` branches

### 3. Test Locally

Always test your changes before committing:

```bash
# Build with kustomize
kubectl kustomize .

# Check for valid YAML
kubectl kustomize . | kubectl apply --dry-run=client -f -

# Or use the validation script
./scripts/validate-manifests.sh
```

### 4. Commit Your Changes

Use clear, descriptive commit messages:

```bash
git add .
git commit -m "Add ingress resource for demo-app"
```

Good commit message examples:
- `Add ConfigMap for application settings`
- `Update deployment replicas for production`
- `Fix service selector labels`

Bad commit message examples:
- `Update files`
- `Fix`
- `WIP`

### 5. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a pull request to `main` branch on GitHub.

## Pull Request Guidelines

### PR Title

Use a clear, descriptive title:
- `Add: Ingress configuration for demo-app`
- `Update: Increase production replicas to 5`
- `Fix: Correct service port mapping`

### PR Description

Include:
1. **What**: What changes are you making?
2. **Why**: Why are these changes needed?
3. **How**: How did you implement the changes?
4. **Testing**: How did you test the changes?

Example:
```markdown
## What
Add Ingress resource for demo-app to enable external access.

## Why
Users need to access the application from outside the cluster.

## How
- Added ingress.yaml to base/
- Configured host routing for dev and prod
- Added TLS configuration

## Testing
- Tested with `kubectl kustomize environments/dev`
- Verified ingress rules with dry-run
- Checked against existing ingress patterns
```

## Code Review Checklist

Reviewers should check:

- [ ] Kustomize builds successfully on current branch
- [ ] YAML syntax is correct
- [ ] Resource names follow naming conventions
- [ ] Labels and selectors are consistent
- [ ] No hardcoded values that should be parameterized
- [ ] Documentation is updated if needed
- [ ] Changes are minimal and focused
- [ ] Commit messages are clear

## Naming Conventions

### Resources
- Use lowercase with hyphens: `demo-app`, `api-service`
- Include environment prefix via kustomize: `dev-demo-app`, `prod-demo-app`

### Labels
- `app`: Application name
- `environment`: Environment name (dev, production)
- `version`: Application version (if applicable)

### Namespaces
- Use descriptive names: `demo-app`, `monitoring`, `ingress-nginx`

## Common Patterns

### Adding a New Resource

1. Add to `base/` directory
2. Reference in `base/kustomization.yaml`
3. Add environment-specific overlays if needed
4. Test with `kubectl kustomize`

### Environment-Specific Configuration

Configure in the root `kustomization.yaml`:

```yaml
# kustomization.yaml (on main branch for dev)
replicas:
- name: demo-app
  count: 1

namePrefix: dev-

labels:
- pairs:
    environment: dev
```

### Secrets

**NEVER** commit secrets to this repository!

For secrets:
1. Use sealed secrets or external secret operators
2. Reference secret names in manifests
3. Document required secrets in README

## Production Deployment Process

### For Non-Breaking Changes

1. Merge PR to `main`
2. Verify deployment in dev cluster
3. Create PR from `main` to `production`
4. Get approval from team lead
5. Merge to `production`

### For Breaking Changes

1. Coordinate with team
2. Plan maintenance window
3. Update documentation first
4. Follow standard promotion process
5. Monitor closely after deployment

## Rollback Procedure

If a deployment causes issues:

### Quick Rollback (Git)
```bash
# On the affected branch
git revert <commit-hash>
git push origin <branch-name>
```

ArgoCD will automatically sync the rollback.

### Manual Rollback (ArgoCD)
```bash
# Using ArgoCD CLI
argocd app rollback demo-platform-dev <revision>
```

### Emergency Rollback (kubectl)
```bash
# Direct kubectl (breaks GitOps - use only in emergency)
kubectl rollout undo deployment/demo-app -n demo-app
```

After emergency rollback, revert the Git changes to restore GitOps state.

## Questions or Issues?

- Check existing issues on GitHub
- Review the SETUP.md guide
- Ask in team chat
- Create an issue for discussions

## License

By contributing, you agree that your contributions will be licensed under the same license as this project.
