output "account_name" {
  value = azurerm_cosmosdb_account.this.name
}

output "id" {
  value = azurerm_cosmosdb_account.this.id
}

output "mongodb_connection_string" {
  value     = azurerm_cosmosdb_account.this.connection_strings[0]
  sensitive = true
}
