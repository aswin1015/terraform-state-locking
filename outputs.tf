output "resource_group_name" {
  description = "Name of the Azure Resource Group."
  value       = module.resource_group.name
}

output "acr_login_server" {
  description = "ACR login server URL — use this in build_and_push.ps1."
  value       = module.acr.login_server
}

output "aks_cluster_name" {
  description = "AKS cluster name — run: az aks get-credentials --name <value> --resource-group <rg>"
  value       = module.aks.cluster_name
}

output "aks_oidc_issuer_url" {
  description = "AKS OIDC issuer URL used by Workload Identity."
  value       = module.aks.oidc_issuer_url
}

output "key_vault_name" {
  description = "Azure Key Vault name."
  value       = module.key_vault.name
}

output "key_vault_uri" {
  description = "Azure Key Vault URI — used in SecretProviderClass."
  value       = module.key_vault.vault_uri
}

output "workload_identity_client_id" {
  description = "Managed Identity client ID — used in workload-identity-sa.yaml annotation."
  value       = module.workload_identity.client_id
}

output "workload_identity_tenant_id" {
  description = "Tenant ID — used in SecretProviderClass."
  value       = data.azurerm_client_config.current.tenant_id
}

output "cosmosdb_account_name" {
  description = "Cosmos DB account name."
  value       = module.cosmosdb.account_name
}

output "storage_account_name" {
  description = "Blob storage account name."
  value       = module.storage.account_name
}

output "app_insights_connection_string" {
  description = "Application Insights connection string."
  value       = module.monitoring.app_insights_connection_string
  sensitive   = true
}

output "doc_intelligence_endpoint" {
  description = "Azure AI Document Intelligence endpoint URL."
  value       = module.doc_intelligence.endpoint
}

output "next_steps" {
  description = "Commands to run after terraform apply."
  value       = <<-EOT
    # 1. Get kubectl credentials
    az aks get-credentials --resource-group ${module.resource_group.name} --name ${module.aks.cluster_name}

    # 2. Substitute placeholders and apply K8s manifests
    # (provision-aks.ps1 handles this automatically, but you can also do it manually)
    # Replace __ACR_NAME__, __MANAGED_IDENTITY_CLIENT_ID__, __KEY_VAULT_NAME__, __TENANT_ID__
    # in the k8s/ directory with the values above, then:
    kubectl apply -f k8s/ --recursive

    # 3. Check pod status
    kubectl get pods -n aegis
  EOT
}
