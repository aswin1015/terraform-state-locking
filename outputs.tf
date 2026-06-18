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
    # 1. Get kubectl credentials (admin = cert-based, matches the TF providers)
    az aks get-credentials --resource-group ${module.resource_group.name} --name ${module.aks.cluster_name} --admin

    # 2. Build & push images to ACR
    #    (build_and_push.ps1 — uses ACR login server: ${module.acr.login_server})

    # 3. Deploy the application via the Helm chart (helm/aegis-health)
    helm upgrade --install aegis ./helm/aegis-health \
      --namespace ${var.k8s_namespace} --create-namespace \
      --set global.acrLoginServer=${module.acr.login_server} \
      --set workloadIdentity.clientId=${module.workload_identity.client_id} \
      --set keyVault.name=${module.key_vault.name} \
      --set keyVault.tenantId=${data.azurerm_client_config.current.tenant_id}

    # 4. Check rollout & get the public Gateway IP
    kubectl get pods -n ${var.k8s_namespace}
    kubectl get gateway aegis-gateway -n ${var.k8s_namespace} -o jsonpath='{.status.addresses[0].value}'
  EOT
}
