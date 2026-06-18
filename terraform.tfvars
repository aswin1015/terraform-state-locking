environment         = "dev"
workload_name       = "aegis"
resource_group_name = "aswin-rg"
location            = "Central India"

# ── AKS ──────────────────────────────────────────────────────────────────────
aks_cluster_name       = "aegis-aks"
aks_kubernetes_version = "1.29"
aks_node_count         = 3
aks_node_vm_size       = "Standard_D2s_v3"

# ── ACR ──────────────────────────────────────────────────────────────────────
# Must be globally unique, lowercase, no hyphens
acr_name = "aegisacraswin"
acr_sku  = "Basic"

# ── Key Vault ─────────────────────────────────────────────────────────────────
# Must be globally unique, 3-24 chars
key_vault_name = "aegis-kv-aswin"

# ── Secrets — set these via env vars in CI/CD ─────────────────────────────────
# export TF_VAR_jwt_secret="..."
# export TF_VAR_postgres_password="..."
# export TF_VAR_gemini_api_key="..."
# export TF_VAR_azure_ai_key="..."
jwt_secret        = "REPLACE_WITH_STRONG_SECRET"
postgres_password = "AegisPostgres2026!"
gemini_api_key    = ""
azure_ai_endpoint = ""
azure_ai_key      = ""

# ── Cosmos DB ────────────────────────────────────────────────────────────────
cosmosdb_account_name  = "aegis-csdb-aswin"
cosmosdb_database_name = "ai-health-agent"

# ── Storage ──────────────────────────────────────────────────────────────────
storage_account_name_prefix = "aegishealthst"
storage_container_names     = ["health-records", "medical-images", "uploads", "exports"]

# ── Azure AI Document Intelligence ───────────────────────────────────────────
doc_intelligence_name = "aegis-docai-aswin3"

# ── Communication Services ────────────────────────────────────────────────────
communication_service_name = "aegiscs"
email_service_name         = "aegis-email"
email_domain_name          = "AzureManagedDomain"
email_domain_management    = "AzureManaged"

tags = {
  owner      = "platform"
  project    = "aegis-health"
  managed-by = "terraform"
}
