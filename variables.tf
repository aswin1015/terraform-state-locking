# ─── Environment ──────────────────────────────────────────────────────────────
variable "environment" {
  description = "Deployment environment name (dev / test / prod)."
  type        = string
  default     = "dev"
}

variable "workload_name" {
  description = "Short workload identifier used in all Azure resource names."
  type        = string
  default     = "aegis"
}

variable "resource_group_name" {
  description = "Azure Resource Group name."
  type        = string
  default     = "aswin-rg"
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "Central India"
}

variable "tags" {
  description = "Common resource tags applied to all Azure resources."
  type        = map(string)
  default     = {}
}

# ─── Networking ───────────────────────────────────────────────────────────────
variable "vnet_name" {
  description = "Virtual Network name."
  type        = string
  default     = "aegis-vnet"
}

variable "vnet_address_space" {
  description = "VNet CIDR block."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Subnet map. AKS needs a /22+ for node pools. pe-subnet for private endpoints."
  type = map(object({
    address_prefixes   = list(string)
    delegation_name    = optional(string)
    delegation_service = optional(string)
  }))
  default = {
    # AKS nodes + pods subnet — /22 gives ~1022 IPs
    "aks-subnet" = {
      address_prefixes = ["10.0.0.0/22"]
    }
    # Private endpoints (CosmosDB, Storage, Key Vault)
    "pe-subnet" = {
      address_prefixes = ["10.0.10.0/24"]
    }
  }
}

# ─── Azure Container Registry ─────────────────────────────────────────────────
variable "acr_name" {
  description = "Globally unique ACR name (lowercase alphanumeric, 5-50 chars)."
  type        = string
  default     = "aegisacr"
}

variable "acr_sku" {
  description = "ACR SKU: Basic | Standard | Premium."
  type        = string
  default     = "Basic"
}

# ─── AKS Cluster ──────────────────────────────────────────────────────────────
variable "aks_cluster_name" {
  description = "AKS cluster name."
  type        = string
  default     = "aegis-aks"
}

variable "aks_kubernetes_version" {
  description = "Kubernetes version for the AKS cluster."
  type        = string
  default     = "1.29"
}

variable "aks_node_count" {
  description = "Initial number of nodes in the default node pool."
  type        = number
  default     = 3
}

variable "aks_node_vm_size" {
  description = "VM size for AKS nodes."
  type        = string
  default     = "Standard_D2s_v3"
}

# ─── Kubernetes Workload Identity ─────────────────────────────────────────────
variable "k8s_namespace" {
  description = "Kubernetes namespace for the application."
  type        = string
  default     = "aegis"
}

variable "k8s_service_account_name" {
  description = "Kubernetes ServiceAccount name used by Workload Identity."
  type        = string
  default     = "aegis-workload-identity"
}

# ─── Azure Key Vault ──────────────────────────────────────────────────────────
variable "key_vault_name" {
  description = "Globally unique Azure Key Vault name (3-24 chars)."
  type        = string
  default     = "aegis-kv"
}

# ─── Secrets (sensitive — set via TF_VAR_* env vars or tfvars) ────────────────
variable "jwt_secret" {
  description = "JWT signing secret for api-gateway."
  type        = string
  sensitive   = true
}

variable "postgres_password" {
  description = "PostgreSQL password for the in-cluster imaging database."
  type        = string
  sensitive   = true
  default     = "AegisPostgres2026!"
}

variable "gemini_api_key" {
  description = "Google Gemini API key for the AI service."
  type        = string
  sensitive   = true
  default     = ""
}

variable "azure_ai_endpoint" {
  description = "Azure AI Foundry endpoint for the Diagnostic Agent."
  type        = string
  default     = ""
}

variable "azure_ai_key" {
  description = "Azure AI Foundry API key for the Diagnostic Agent."
  type        = string
  sensitive   = true
  default     = ""
}

# ─── Cosmos DB ────────────────────────────────────────────────────────────────
variable "cosmosdb_account_name" {
  description = "Globally unique Cosmos DB account name."
  type        = string
  default     = "aegis-csdb"
}

variable "cosmosdb_database_name" {
  description = "Cosmos DB Mongo database name."
  type        = string
  default     = "ai-health-agent"
}

# ─── Storage ──────────────────────────────────────────────────────────────────
variable "storage_account_name_prefix" {
  description = "Storage account name prefix (max 24 lowercase alphanumeric chars)."
  type        = string
  default     = "aegishealthst"
}

variable "storage_container_names" {
  description = "Blob containers to create."
  type        = set(string)
  default     = ["health-records", "medical-images", "uploads", "exports"]
}

# ─── Azure AI Document Intelligence ──────────────────────────────────────────
variable "doc_intelligence_name" {
  description = "Globally unique Azure AI Document Intelligence name."
  type        = string
  default     = "aegis-docai"
}

# ─── Azure Communication Services ────────────────────────────────────────────
variable "communication_service_name" {
  description = "Azure Communication Services resource name."
  type        = string
  default     = "aegiscs"
}

variable "email_service_name" {
  description = "Email Communication Service resource name."
  type        = string
  default     = "aegis-email"
}

variable "email_domain_name" {
  description = "Email domain name."
  type        = string
  default     = "AzureManagedDomain"
}

variable "email_domain_management" {
  description = "Email domain management mode: AzureManaged or CustomerManaged."
  type        = string
  default     = "AzureManaged"
}
