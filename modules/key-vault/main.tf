# ── Key Vault ─────────────────────────────────────────────────────────────────
resource "azurerm_key_vault" "this" {
  name                       = var.key_vault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false # Allow destroy in dev; set true for prod
  tags                       = var.tags
}

# ── Access policy for Terraform runner — full CRUD to load secrets ─────────────
resource "azurerm_key_vault_access_policy" "deployer" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.tenant_id
  object_id    = var.deployer_object_id

  secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
}

# ── Access policy for Workload Identity — pods only need Get/List ─────────────
resource "azurerm_key_vault_access_policy" "workload_identity" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.tenant_id
  object_id    = var.workload_identity_object_id

  secret_permissions = ["Get", "List"]
}

# ── Store secrets in Key Vault ────────────────────────────────────────────────
resource "azurerm_key_vault_secret" "this" {
  for_each = var.secrets

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [azurerm_key_vault_access_policy.deployer]
}
