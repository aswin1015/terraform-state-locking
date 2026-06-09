output "id" {
  description = "Resource ID of the Document Intelligence account."
  value       = azurerm_cognitive_account.this.id
}

output "endpoint" {
  description = "Endpoint URL for the Document Intelligence account."
  value       = azurerm_cognitive_account.this.endpoint
}

output "primary_key" {
  description = "Primary access key for the Document Intelligence account."
  value       = azurerm_cognitive_account.this.primary_access_key
  sensitive   = true
}
