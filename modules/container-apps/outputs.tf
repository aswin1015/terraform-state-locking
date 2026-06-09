output "environment_id" {
  value = azurerm_container_app_environment.this.id
}

output "environment_default_domain" {
  value = azurerm_container_app_environment.this.default_domain
}

output "app_ids" {
  value = { for name, app in azurerm_container_app.this : name => app.id }
}

output "app_fqdns" {
  value = { for name, app in azurerm_container_app.this : name => app.latest_revision_fqdn }
}
