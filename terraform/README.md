# Terraform Infrastructure CI/CD with GitHub Actions

## Remote State
- State is stored in GCS bucket: `tfstate-fid-wallet-dev` (in `europe-west1`)
- Locking and state consistency are managed by Terraform and GCS

## CI/CD Pipeline
- Defined in `.github/workflows/terraform.yml`
- Uses Workload Identity Federation for secure, keyless GCP auth
- Runs `init`, `validate`, `plan` on PRs; `apply` on `main` branch

## Manual Setup Checklist

### 1. Create the GCS bucket for state
```sh
gsutil mb -l europe-west1 gs://tfstate-fid-wallet-dev
gsutil versioning set on gs://tfstate-fid-wallet-dev
```

### 2. Set up Workload Identity Federation (one-time)
- Follow: https://github.com/google-github-actions/auth#setting-up-workload-identity-federation
- Create a Workload Identity Pool and Provider in GCP
- Create a Service Account with these roles:
  - roles/storage.admin (for state bucket)
  - roles/iam.serviceAccountTokenCreator
  - roles/resourcemanager.projectIamAdmin (if you want to manage IAM)
  - Any other roles needed for your infra
- Allow the pool to impersonate the service account

### 3. Add GitHub Secrets
- `WIF_PROVIDER`: Full resource name of the Workload Identity Provider
- `GCP_SA_EMAIL`: Service Account email

### 4. First-time Terraform Init
- On first run, you may need to run `terraform init` locally to migrate state to GCS

## Usage
- All changes to `main` branch will be applied automatically
- PRs will show a plan for review

---
For more details, see the official docs:
- [Terraform GCS Backend](https://developer.hashicorp.com/terraform/language/settings/backends/gcs)
- [Google GitHub Actions Auth](https://github.com/google-github-actions/auth)

