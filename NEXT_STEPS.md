# Next Steps

This repository has been set up as a GitOps deployment repository for ArgoCD. Here's what you need to do to complete the setup:

## 1. Merge This Pull Request

Review and merge this pull request to the `main` branch. This will establish the base structure for your GitOps repository.

## 2. Create the Production Branch

After merging to `main`, create the production branch using the provided script:

```bash
# Pull the latest changes
git checkout main
git pull origin main

# Run the script to create production branch
./scripts/create-production-branch.sh
```

Or manually:

```bash
git checkout main
git pull origin main
git checkout -b production
git push -u origin production
```

## 3. Set Up Branch Protection Rules

Configure branch protection on GitHub:

### For `main` branch:
- Go to Settings → Branches → Add rule
- Branch name pattern: `main`
- Enable:
  - ✅ Require pull request reviews before merging
  - ✅ Require status checks to pass before merging
  - ✅ Require branches to be up to date before merging

### For `production` branch:
- Go to Settings → Branches → Add rule
- Branch name pattern: `production`
- Enable:
  - ✅ Require pull request reviews before merging (2+ reviewers recommended)
  - ✅ Require status checks to pass before merging
  - ✅ Require branches to be up to date before merging
  - ✅ Include administrators (optional but recommended)

## 4. Configure ArgoCD Applications

### For Development Cluster

Connect to your dev cluster and apply the ArgoCD application:

```bash
# Ensure you're connected to the dev cluster
kubectl config use-context <dev-cluster-context>

# Verify ArgoCD is installed
kubectl get pods -n argocd

# Apply the dev application
kubectl apply -f argocd/dev-application.yaml -n argocd

# Verify the application was created
kubectl get application demo-platform-dev -n argocd

# Or use ArgoCD CLI
argocd app get demo-platform-dev
```

### For Production Cluster

Connect to your prod cluster and apply the ArgoCD application:

```bash
# Ensure you're connected to the prod cluster
kubectl config use-context <prod-cluster-context>

# Verify ArgoCD is installed
kubectl get pods -n argocd

# Apply the prod application
kubectl apply -f argocd/prod-application.yaml -n argocd

# Verify the application was created
kubectl get application demo-platform-prod -n argocd

# Or use ArgoCD CLI
argocd app get demo-platform-prod
```

## 5. Update ArgoCD Application Configurations (If Using External Clusters)

If your production cluster is different from where ArgoCD is running, you'll need to update the destination in the ArgoCD application files:

```yaml
# In argocd/prod-application.yaml
destination:
  # Option 1: Use cluster server URL
  server: https://your-production-cluster-api-server
  
  # Option 2: Use cluster name (if registered with ArgoCD)
  name: production-cluster
  
  namespace: demo-app
```

To register an external cluster with ArgoCD:

```bash
# List contexts
kubectl config get-contexts

# Add cluster to ArgoCD
argocd cluster add <context-name>

# List registered clusters
argocd cluster list
```

## 6. Verify Deployments

### Check ArgoCD UI

1. Access ArgoCD UI: `kubectl port-forward svc/argocd-server -n argocd 8080:443`
2. Open browser: `https://localhost:8080`
3. Login with ArgoCD credentials
4. Verify both applications are visible and syncing

### Check via CLI

```bash
# Check application status
argocd app list

# Get detailed status
argocd app get demo-platform-dev
argocd app get demo-platform-prod

# View sync history
argocd app history demo-platform-dev
```

### Check Deployed Resources

```bash
# In dev cluster
kubectl get all -n demo-app -l environment=dev

# In prod cluster
kubectl get all -n demo-app -l environment=production
```

## 7. Customize for Your Application

Now that the structure is set up, customize it for your actual application:

1. **Update base manifests** in `base/` directory:
   - Replace nginx with your application image
   - Update resource limits and requests
   - Add additional resources (ConfigMaps, Secrets, etc.)

2. **Customize environment configuration**:
   - Update `kustomization.yaml` on `main` branch for dev-specific config
   - Update `kustomization.yaml` on `production` branch for prod-specific config

3. **Test changes locally**:
   ```bash
   ./scripts/validate-manifests.sh
   ```

4. **Commit and push changes**:
   ```bash
   git add .
   git commit -m "Update application configuration"
   git push origin main
   ```

5. **Watch ArgoCD sync** your changes automatically!

## 8. Set Up CI/CD Integration (Optional)

Consider setting up CI/CD to automatically update image tags:

1. **Build and push** your application image in CI
2. **Update** the image tag in the manifests
3. **Commit and push** the changes
4. **ArgoCD syncs** the new version automatically

Example CI pipeline snippet:

```yaml
# .github/workflows/deploy.yaml
- name: Update image tag
  run: |
    kustomize edit set image nginx=myapp:${{ github.sha }}
    git config user.name "GitHub Actions"
    git config user.email "actions@github.com"
    git commit -am "Update dev image to ${{ github.sha }}"
    git push origin main
```

## 9. Set Up Monitoring and Notifications

Configure ArgoCD notifications to stay informed:

1. Install ArgoCD notifications: https://argocd-notifications.readthedocs.io/
2. Configure Slack/Email notifications for sync events
3. Set up alerts for failed syncs or health issues

## 10. Documentation

Update the documentation as you customize:

- Update `README.md` with application-specific details
- Document any custom configuration in `SETUP.md`
- Add deployment procedures to `CONTRIBUTING.md`

## Troubleshooting

If you encounter issues:

1. **Check ArgoCD logs**: `kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller`
2. **Validate manifests**: `./scripts/validate-manifests.sh`
3. **Check application events**: `argocd app get <app-name>`
4. **Review sync status**: In ArgoCD UI or via `argocd app sync <app-name>`

## Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kustomize Documentation](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)
- [Repository README](README.md)
- [Setup Guide](SETUP.md)
- [Contributing Guide](CONTRIBUTING.md)
- [Quick Reference](QUICK_REFERENCE.md)

## Questions?

If you have questions or need help:
1. Check the documentation files in this repository
2. Review ArgoCD and Kubernetes documentation
3. Open an issue in this repository

---

**You're all set!** 🚀 Start deploying with GitOps!
