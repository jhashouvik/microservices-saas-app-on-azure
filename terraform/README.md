# Terraform scaffold for "Microservices SaaS App on Azure"

Generated from the architecture diagram (provider: azure). This is a
**starting scaffold**, not a finished production module -- it creates NEW
network resources matching your diagram's groups (it doesn't import any
existing VPCs/VNets), and has no knowledge of your IAM policies or naming
conventions, so those are exposed as required variables (no default)
rather than guessed.

## Files
- `main.tf` -- provider/backend config, one network/subnet resource per
  diagram group (VPC/VNet boundary), and one resource block per diagram node
- `variables.tf` -- all inputs, including required ones with no default
- `outputs.tf` -- convenience outputs (endpoints, ids, ARNs)
- `secrets.tf` -- secrets-manager entries mirroring any generated/managed credentials
- `terraform.tfvars.example` -- placeholders for non-secret required variables

## Secret handling
No secret value is ever written into these files. Credential-shaped
variables are declared `sensitive = true` with no default. Supply them via:
- `TF_VAR_<name>` environment variables (good for local/manual runs), or
- a `*.auto.tfvars` file added to `.gitignore` (never commit it), or
- your CI/CD pipeline's secret store (GitHub Actions secrets, GitLab CI
  variables, HashiCorp Vault, etc.)

Where a resource generates its own secret (e.g. an Azure AD app's client
secret), it's mirrored into the cloud provider's secrets manager
(Secrets Manager / Key Vault / Secret Manager) so the running application
reads it at runtime instead of it living in plaintext config.

## Usage
```
terraform init
terraform plan
terraform apply
```

Review `terraform plan` carefully -- required variables with no default
must be supplied before `apply` will succeed.
