# ── User Assigned Managed Identity ────────────────────────────────────────────
resource "azurerm_user_assigned_identity" "this" {
  name                = var.identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# ── Federated Credential — binds AKS OIDC → Managed Identity ──────────────────
# This allows pods using the K8s ServiceAccount to authenticate as this identity.
resource "azurerm_federated_identity_credential" "this" {
  name                = "${var.identity_name}-fedcred"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.this.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.aks_oidc_issuer_url
  subject             = "system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account}"
}
