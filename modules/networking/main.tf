resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  private_endpoint_network_policies = each.key == "pe-subnet" ? "Disabled" : "Enabled"

  dynamic "delegation" {
    for_each = each.value.delegation_service == null ? [] : [each.value]

    content {
      name = coalesce(delegation.value.delegation_name, "${each.key}-delegation")

      service_delegation {
        name    = delegation.value.delegation_service
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }
}
