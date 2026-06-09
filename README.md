# Health Care Terraform

Module-based Azure Terraform for the health care container app stack.

## Layout

- `main.tf` wires the modules together.
- `providers.tf` pins Terraform providers.
- `backend.tf` keeps Azure Storage remote state locking.
- `modules/` contains reusable infrastructure modules.
- `environments/dev|test|prod` contains per-environment `terraform.tfvars` and backend keys.

## Containers

The Container Apps module is populated from `../Health-care/update_containers.sh`:

- `api-gateway`: `insurancecr.azurecr.io/aegis-api-gateway:v1.0.6`
- `notification-worker`: `insurancecr.azurecr.io/aegis-notification-worker:v1.0.6`
- `client`: `insurancecr.azurecr.io/aegis-client:v1.0.6`

The default network uses `10.0.10.0/24` for Application Gateway, `10.0.20.0/24` for Container Apps, `10.0.30.0/24` for private endpoints, and `10.0.40.0/24` for Function App VNet integration.

## Commands

```bash
terraform init -backend-config=environments/dev/backend.hcl
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

For a private Azure Container Registry, pass `container_registry_username` and `container_registry_password` through environment variables or a secure tfvars file.

Storage account names and Cosmos DB account names must be globally unique in Azure. Adjust the environment tfvars if a name is already taken.
