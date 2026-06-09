output "communication_service_id" {
  value = azurerm_communication_service.this.id
}

output "email_domain_id" {
  value = azurerm_email_communication_service_domain.this.id
}

output "primary_connection_string" {
  value     = azurerm_communication_service.this.primary_connection_string
  sensitive = true
}
