output "workspace_id" {
  value = azurerm_log_analytics_workspace.this.id
}

output "primary_shared_key" {
  value     = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive = true
}

output "application_insights_connection_string" {
  value     = azurerm_application_insights.this.connection_string
  sensitive = true
}
