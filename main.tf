locals {
  common_tags = merge(var.tags, {
    environment = var.environment
    workload    = var.workload_name
    managed-by  = "terraform"
  })

  # Resource name prefix used across all new modules
  prefix = "${var.workload_name}-${var.environment}"
}

# ─── Data Sources ─────────────────────────────────────────────────────────────
data "azurerm_client_config" "current" {}

# ─── Resource Group ───────────────────────────────────────────────────────────
module "resource_group" {
  source = "./modules/resource-group"

  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# ─── Networking (VNet + Subnets for AKS) ─────────────────────────────────────
module "networking" {
  source = "./modules/networking"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vnet_name           = var.vnet_name
  address_space       = var.vnet_address_space
  subnets             = var.subnets
  tags                = local.common_tags
}

# ─── Monitoring (Log Analytics + Application Insights) ────────────────────────
module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  workspace_name      = "${local.prefix}-law"
  tags                = local.common_tags
}

# ─── Azure Container Registry ─────────────────────────────────────────────────
module "acr" {
  source = "./modules/acr"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = var.acr_name
  sku                 = var.acr_sku
  tags                = local.common_tags
}

# ─── AKS Cluster (Workload Identity + Key Vault CSI add-on) ──────────────────
module "aks" {
  source = "./modules/aks"

  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  cluster_name               = var.aks_cluster_name
  kubernetes_version         = var.aks_kubernetes_version
  node_count                 = var.aks_node_count
  node_vm_size               = var.aks_node_vm_size
  subnet_id                  = module.networking.subnet_ids["aks-subnet"]
  log_analytics_workspace_id = module.monitoring.workspace_id
  acr_id                     = module.acr.id
  tags                       = local.common_tags
}

# ─── Workload Identity (Managed Identity + Federated Credentials) ─────────────
module "workload_identity" {
  source = "./modules/workload-identity"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  identity_name       = "${local.prefix}-workload-id"
  aks_oidc_issuer_url = module.aks.oidc_issuer_url
  k8s_namespace       = var.k8s_namespace
  k8s_service_account = var.k8s_service_account_name
  tags                = local.common_tags
}

# ─── Azure Key Vault ──────────────────────────────────────────────────────────
module "key_vault" {
  source = "./modules/key-vault"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  key_vault_name      = var.key_vault_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  # Grant the Workload Identity read access
  workload_identity_object_id = module.workload_identity.principal_id
  # Grant the deploying principal (Terraform runner) full access to load secrets
  deployer_object_id = data.azurerm_client_config.current.object_id
  tags               = local.common_tags

  # ── Secrets to store ───────────────────────────────────────────────────────
  secrets = {
    "kv-mongodb-uri"        = module.cosmosdb.mongodb_connection_string
    "kv-jwt-secret"         = var.jwt_secret
    "kv-postgres-url"       = "postgresql://aegis:${var.postgres_password}@postgres-service:5432/imaging"
    "kv-postgres-password"  = var.postgres_password
    "kv-azure-storage-conn" = module.storage.primary_connection_string
    "kv-gemini-api-key"     = var.gemini_api_key
    "kv-azure-ai-endpoint"  = var.azure_ai_endpoint
    "kv-azure-ai-key"       = var.azure_ai_key
    "kv-appinsights-conn"   = module.monitoring.app_insights_connection_string
  }
}

# ─── Cosmos DB for MongoDB API ────────────────────────────────────────────────
module "cosmosdb" {
  source = "./modules/cosmosdb"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  account_name        = var.cosmosdb_account_name
  database_name       = var.cosmosdb_database_name
  subnet_id           = module.networking.subnet_ids["pe-subnet"]
  vnet_id             = module.networking.vnet_id
  tags                = local.common_tags
}

# ─── Azure Blob Storage (medical images) ─────────────────────────────────────
module "storage" {
  source = "./modules/storage"

  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  account_name_prefix        = var.storage_account_name_prefix
  container_names            = var.storage_container_names
  private_endpoint_subnet_id = module.networking.subnet_ids["pe-subnet"]
  vnet_id                    = module.networking.vnet_id
  tags                       = local.common_tags
}

# ─── Azure AI Document Intelligence ──────────────────────────────────────────
module "doc_intelligence" {
  source = "./modules/doc-intelligence"

  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  name                       = var.doc_intelligence_name
  private_endpoint_subnet_id = module.networking.subnet_ids["pe-subnet"]
  vnet_id                    = module.networking.vnet_id
  tags                       = local.common_tags
}

# ─── Azure Communication Services ────────────────────────────────────────────
module "communication" {
  source = "./modules/communication"

  resource_group_name        = module.resource_group.name
  communication_service_name = var.communication_service_name
  email_service_name         = var.email_service_name
  email_domain_name          = var.email_domain_name
  domain_management          = var.email_domain_management
  tags                       = local.common_tags
}

# ─── KGateway (Gateway API CRDs + KGateway Helm) ─────────────────────────────
module "kgateway" {
  source = "./modules/kgateway"

  # Helm provider is configured via AKS kubeconfig above
  depends_on = [module.aks]
}
