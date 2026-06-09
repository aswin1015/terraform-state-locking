# Health App Terraform

Terraform configuration for deploying the Azure infrastructure needed by the health application.

This stack uses local Terraform state. The `backend.tf` file is intentionally empty, so no Azure Storage remote backend or state locking is configured.

## What Is Included

### Resource Group

- Creates the Azure resource group used by the whole application.
- Applies common tags such as `environment`, `workload`, and any custom tags from `terraform.tfvars`.

### Networking

- Creates a virtual network.
- Creates dedicated subnets for:
  - Application Gateway
  - Container Apps Environment
  - Private Endpoints
  - Function App VNet integration
- Configures subnet delegation for Container Apps and Function App integration.
- Disables private endpoint network policies on the private endpoint subnet.

### Monitoring

- Creates a Log Analytics Workspace.
- Creates Application Insights connected to the workspace.
- Supplies logging configuration for Azure Container Apps.

### Cosmos DB

- Creates a Cosmos DB account using the MongoDB API.
- Creates the MongoDB database.
- Disables public network access.
- Creates a private endpoint for Cosmos DB.
- Creates and links the private DNS zone for MongoDB private access.
- Exposes the primary MongoDB connection string for the app containers and Function App.

### Storage

- Creates a private Azure Storage Account.
- Creates blob containers from `storage_container_names`.
- Disables public network access.
- Creates a private endpoint for blob storage.
- Creates and links the private DNS zone for blob private access.

### Azure Communication Services

- Creates an Azure Communication Services resource.
- Creates an Email Communication Service.
- Creates the configured email domain.
- Associates the email domain with Communication Services.
- Exposes the Communication Services connection string for the Function App.

### Function App

- Creates a Linux Azure Function App.
- Creates the Function App service plan.
- Enables system-assigned managed identity.
- Configures Node.js runtime.
- Injects application settings for:
  - Cosmos DB MongoDB connection
  - Communication Services connection
  - VNet routing
- Integrates the Function App with the VNet.
- Creates a private endpoint and private DNS zone for the Function App.

### Container Apps

- Creates an Azure Container Apps Environment.
- Deploys these container apps:
  - `api-gateway`
  - `notification-worker`
  - `client`
- Configures replicas, CPU, memory, ingress, environment variables, and secrets.
- Uses the configured Azure Container Registry server and optional registry credentials.

Default container images:

```text
insurancecr.azurecr.io/aegis-api-gateway:v1.0.6
insurancecr.azurecr.io/aegis-notification-worker:v1.0.6
insurancecr.azurecr.io/aegis-client:v1.0.6
```

### Application Gateway

- Creates a public IP address.
- Creates an Application Gateway with WAF v2.
- Routes HTTP traffic to the configured backend Container App.
- Uses a health probe path, defaulting to `/`.

## Default Network Layout

```text
10.0.10.0/24  appgtw-subnet
10.0.20.0/24  container-app-env
10.0.30.0/24  pe-subnet
10.0.40.0/24  function-subnet
```

## Important Variables

- `resource_group_name`: Azure resource group name.
- `location`: Azure region.
- `container_registry_server`: ACR login server.
- `container_image_version`: Image tag used by all app containers.
- `jwt_secret`: API Gateway JWT secret.
- `cosmosdb_account_name`: Globally unique Cosmos DB account name.
- `storage_account_name_prefix`: Globally unique storage account name prefix.
- `function_app_name`: Globally unique Function App name.
- `communication_service_name`: Communication Services resource name.
- `email_service_name`: Email Communication Service resource name.
- `app_gateway_backend_app_name`: Container App routed by Application Gateway.

## How To Run

From this directory:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

To use the root `terraform.tfvars`, no extra flag is needed. Terraform loads it automatically.

For environment-specific tfvars:

```bash
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

## Notes Before Apply

- Make sure you are logged in to Azure CLI with the right subscription.
- Make sure globally unique names are available, especially Cosmos DB, Storage Account, and Function App names.
- Make sure the container images exist in the configured registry.
- If the registry is private, set `container_registry_username` and `container_registry_password` securely.
- Since local state is used, keep `terraform.tfstate` safe and do not delete it after applying.
