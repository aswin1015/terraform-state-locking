locals {
  registry_enabled = var.container_registry_username != null && var.container_registry_password != null
}

resource "azurerm_container_app_environment" "this" {
  name                           = var.environment_name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  infrastructure_subnet_id       = var.infrastructure_subnet_id
  internal_load_balancer_enabled = var.internal_load_balancer_enabled
  tags                           = var.tags
}

resource "azurerm_container_app" "this" {
  for_each = var.apps

  name                         = each.key
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.this.id
  revision_mode                = "Single"
  tags                         = var.tags

  dynamic "secret" {
    for_each = merge(
      each.value.secrets,
      local.registry_enabled ? { REGISTRY_PASSWORD = var.container_registry_password } : {}
    )

    content {
      name  = lower(replace(secret.key, "_", "-"))
      value = secret.value
    }
  }

  dynamic "registry" {
    for_each = local.registry_enabled ? [1] : []

    content {
      server               = var.container_registry_server
      username             = var.container_registry_username
      password_secret_name = "registry-password"
    }
  }

  template {
    min_replicas = each.value.min_replicas
    max_replicas = each.value.max_replicas

    container {
      name   = each.key
      image  = each.value.image
      cpu    = each.value.cpu
      memory = each.value.memory

      dynamic "env" {
        for_each = each.value.env

        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = each.value.secrets

        content {
          name        = env.key
          secret_name = lower(replace(env.key, "_", "-"))
        }
      }
    }
  }

  dynamic "ingress" {
    for_each = each.value.target_port == null ? [] : [each.value]

    content {
      external_enabled = ingress.value.external_enabled
      target_port      = ingress.value.target_port
      transport        = "auto"

      traffic_weight {
        percentage      = 100
        latest_revision = true
      }
    }
  }
}
