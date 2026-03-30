# Terraform Infrastructure for fid-wallet

This directory contains the Terraform configuration for deploying the fid-wallet GCP infrastructure.

## Structure
- `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`: Root configuration and module wiring
- `terraform.tfvars.example`: Example variable file (copy to `terraform.tfvars` and fill in values)
- `modules/`: Contains all infrastructure modules (cloudrun, cloudsql, storage, secrets, firebase, cicd, networking)

## Usage
1. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in your values.
2. Export sensitive variables as environment variables (see comments in `terraform.tfvars.example`).
3. Run `terraform init` to initialize the project.
4. Run `terraform plan` to review changes.
5. Run `terraform apply` to provision resources.

## Modules
Each module is self-contained and manages a specific GCP resource or set of resources. See each module's `main.tf` for details.

## Best Practices
- Never commit secrets or `terraform.tfvars` to git.
- Use remote state (GCS backend) for team environments.
- Review IAM permissions and labels for all resources.

