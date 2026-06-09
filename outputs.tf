output "resource_group_name" {
  value = module.resource_group.name
}

output "app_gateway_public_ip" {
  value = module.app_gateway.public_ip_address
}

output "container_app_fqdns" {
  value = module.container_apps.app_fqdns
}

output "cosmosdb_account_name" {
  value = module.cosmosdb.account_name
}

output "storage_account_name" {
  value = module.storage.account_name
}

output "function_app_default_hostname" {
  value = module.function_app.default_hostname
}

output "communication_service_id" {
  value = module.communication.communication_service_id
}

output "doc_intelligence_endpoint" {
  description = "Endpoint URL of the Azure AI Document Intelligence resource."
  value       = module.doc_intelligence.endpoint
}
