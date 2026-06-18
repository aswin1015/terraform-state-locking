resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  tags                = var.tags

  # ── Default node pool ──────────────────────────────────────────────────────
  default_node_pool {
    name                = "system"
    node_count          = var.node_count
    vm_size             = var.node_vm_size
    vnet_subnet_id      = var.subnet_id
    os_disk_size_gb     = 50
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    min_count           = var.node_count
    max_count           = var.node_count + 2
  }

  # ── Managed identity for the cluster ──────────────────────────────────────
  identity {
    type = "SystemAssigned"
  }

  # ── OIDC Issuer — required for Workload Identity ───────────────────────────
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # ── Key Vault CSI Secrets Provider add-on ─────────────────────────────────
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  # ── Azure Monitor (Container Insights) ────────────────────────────────────
  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  # ── Network (Azure CNI for VNet integration) ──────────────────────────────
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  # ── Azure RBAC for Kubernetes ─────────────────────────────────────────────
  azure_active_directory_role_based_access_control {
    managed            = true  # Required in azurerm 3.x; defaults to true in 4.x
    azure_rbac_enabled = true
  }
}

# ── Grant AKS permission to pull images from ACR ─────────────────────────────
resource "azurerm_role_assignment" "acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}
