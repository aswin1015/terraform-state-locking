resource "azurerm_service_plan" "this" {
  name                = "${var.name}-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.service_plan_sku_name
  tags                = var.tags
}

resource "azurerm_linux_function_app" "this" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = azurerm_service_plan.this.id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  virtual_network_subnet_id  = var.service_plan_sku_name == "Y1" ? null : var.vnet_integration_subnet_id
  https_only                 = true
  tags                       = var.tags

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      node_version = "20"
    }
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME         = "node"
    # CosmosDB — key name matches what index.js reads (process.env.COSMOS_MONGODB_URI)
    COSMOS_MONGODB_URI               = var.cosmosdb_connection_string
    # Azure Communication Services — both keys the function reads
    ACS_CONNECTION_STRING            = var.communication_service_connection
    COMMUNICATION_SERVICE_CONNECTION = var.communication_service_connection
    ACS_SENDER_ADDRESS               = var.acs_sender_address
    # Azure AI Document Intelligence (Form Recognizer)
    FORM_RECOGNIZER_ENDPOINT         = var.form_recognizer_endpoint
    FORM_RECOGNIZER_KEY              = var.form_recognizer_key
    # Storage — needed by the blobTrigger binding and the buildBlobUrl helper in index.js
    AZURE_STORAGE_CONNECTION_STRING  = var.storage_connection_string
    # VNet / runtime settings
    WEBSITE_CONTENTOVERVNET          = var.service_plan_sku_name == "Y1" ? "0" : "1"
    WEBSITE_RUN_FROM_PACKAGE         = "1"
    WEBSITE_VNET_ROUTE_ALL           = var.service_plan_sku_name == "Y1" ? "0" : "1"
  }
}

resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "${var.name}-sites-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_endpoint" "this" {
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.name}-sites-psc"
    private_connection_resource_id = azurerm_linux_function_app.this.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.this.id]
  }
}
