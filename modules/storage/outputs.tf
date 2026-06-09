output "account_name" {
  value = azurerm_storage_account.this.name
}

output "id" {
  value = azurerm_storage_account.this.id
}

output "primary_access_key" {
  value     = azurerm_storage_account.this.primary_access_key
  sensitive = true
}

output "primary_connection_string" {
  description = "Full connection string for the storage account (used by the Function App blob trigger)."
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}
