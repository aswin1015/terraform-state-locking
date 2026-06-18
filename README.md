# Aegis Health — Terraform Infrastructure
## AKS + Azure Key Vault + ACR + KGateway

This Terraform configuration provisions all Azure infrastructure for **Aegis Health** — migrated from Azure Container Apps to a full **AKS** cluster.

---

## Architecture

```
Azure (aswin-rg / Central India)
├── Azure Container Registry (ACR)       — aegisacraswin
├── AKS Cluster                          — aegis-aks (3× Standard_D2s_v3)
│   ├── OIDC Issuer enabled
│   ├── Workload Identity enabled
│   └── Key Vault CSI Driver add-on
├── User Assigned Managed Identity       — aegis-dev-workload-id
│   └── Federated Credential → AKS OIDC → K8s ServiceAccount
├── Azure Key Vault                      — aegis-kv-aswin
│   └── 9 secrets (MongoDB, JWT, Postgres, Storage, AI keys...)
├── VNet (10.0.0.0/16)
│   ├── aks-subnet    (10.0.0.0/22)
│   └── pe-subnet     (10.0.10.0/24)
├── Cosmos DB (MongoDB API)              — aegis-csdb-aswin
├── Azure Blob Storage                   — aegishealthst...
├── Azure AI Document Intelligence       — aegis-docai-aswin3
├── Azure Communication Services         — aegiscs
├── Log Analytics Workspace + App Insights
└── KGateway (Helm) — Gateway API CRDs + kgateway controller
```

---

## Modules

| Module | Description | Status |
|---|---|---|
| `resource-group` | Azure Resource Group | ✅ Existing |
| `networking` | VNet + Subnets (updated for AKS) | ✅ Updated |
| `monitoring` | Log Analytics + App Insights | ✅ Existing |
| `acr` | Azure Container Registry | 🆕 New |
| `aks` | AKS cluster with OIDC + Workload Identity + CSI | 🆕 New |
| `workload-identity` | Managed Identity + Federated Credential | 🆕 New |
| `key-vault` | Key Vault + access policies + all secrets | 🆕 New |
| `kgateway` | Helm: Gateway API CRDs + KGateway controller | 🆕 New |
| `cosmosdb` | Cosmos DB for MongoDB API | ✅ Existing |
| `storage` | Azure Blob Storage | ✅ Existing |
| `doc-intelligence` | Azure AI Document Intelligence | ✅ Existing |
| `communication` | Azure Communication Services | ✅ Existing |

---

## Quick Start

### Prerequisites

```bash
# Install tools
winget install Microsoft.AzureCLI
winget install Hashicorp.Terraform
winget install Helm.Helm

# Login
az login
az account set --subscription "<subscription-id>"
```

### 1. Set sensitive secrets via env vars

```powershell
$env:TF_VAR_jwt_secret         = "your-strong-jwt-secret"
$env:TF_VAR_postgres_password  = "YourPostgresPass2026!"
$env:TF_VAR_gemini_api_key     = "your-gemini-key"
$env:TF_VAR_azure_ai_key       = "your-azure-ai-key"
$env:TF_VAR_azure_ai_endpoint  = "https://your-ai-foundry.cognitiveservices.azure.com/"
```

### 2. Initialize

```bash
cd terraform-state-locking

terraform init \
  -backend-config="resource_group_name=aswin-rg" \
  -backend-config="storage_account_name=aegishealthstorage" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=terraform.tfstate"
```

### 3. Plan

```bash
terraform plan -var-file="terraform.tfvars" -out=tfplan
```

### 4. Apply

```bash
terraform apply tfplan
```

### 5. Get kubectl credentials

```bash
az aks get-credentials --resource-group aswin-rg --name aegis-aks
kubectl get nodes
```

### 6. Deploy K8s manifests

After apply, update the K8s manifests with Terraform outputs:

```bash
# Get outputs
terraform output acr_login_server            # → use as __ACR_NAME__
terraform output workload_identity_client_id # → use in workload-identity-sa.yaml
terraform output key_vault_name              # → use in secret-provider-class.yaml
terraform output workload_identity_tenant_id # → use in secret-provider-class.yaml

# Run the K8s provisioning script (it substitutes placeholders automatically)
.\k8s\scripts\provision-aks.ps1
```

---

## Sensitive Variables

| Variable | Secret Name | Description |
|---|---|---|
| `jwt_secret` | `TF_VAR_JWT_SECRET` | JWT signing key for api-gateway |
| `postgres_password` | `TF_VAR_POSTGRES_PASSWORD` | In-cluster PostgreSQL password |
| `gemini_api_key` | `TF_VAR_GEMINI_API_KEY` | Google Gemini API key |
| `azure_ai_key` | `TF_VAR_AZURE_AI_KEY` | Azure AI Foundry API key |
| `azure_ai_endpoint` | `TF_VAR_AZURE_AI_ENDPOINT` | Azure AI Foundry endpoint URL |

**Never commit secrets to git.** Use `TF_VAR_*` environment variables or a secrets manager.

---

## Key Outputs After Apply

| Output | Used For |
|---|---|
| `acr_login_server` | `__ACR_NAME__` placeholder in K8s manifests |
| `aks_cluster_name` | `az aks get-credentials` |
| `aks_oidc_issuer_url` | Workload Identity federated credential |
| `key_vault_name` | SecretProviderClass in K8s |
| `key_vault_uri` | SecretProviderClass `keyvaultName` |
| `workload_identity_client_id` | ServiceAccount annotation in K8s |
| `workload_identity_tenant_id` | SecretProviderClass `tenantId` |

---

## CI/CD (GitHub Actions)

The workflow at `.github/workflows/terraform.yml`:

- **PR** → runs `terraform plan` and posts output as PR comment
- **Push to main** → runs `terraform apply` (with manual approval gate)
- **Manual trigger** → choose `plan`, `apply`, or `destroy`

### Required GitHub Secrets

```
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_SUBSCRIPTION_ID
ARM_TENANT_ID
TF_VAR_JWT_SECRET
TF_VAR_POSTGRES_PASSWORD
TF_VAR_GEMINI_API_KEY
TF_VAR_AZURE_AI_KEY
TF_VAR_AZURE_AI_ENDPOINT
```
