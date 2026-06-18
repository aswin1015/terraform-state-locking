output "cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "cluster_id" {
  value = azurerm_kubernetes_cluster.this.id
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.this.kube_config[0]
  sensitive = true
}

# Cert-based local admin credentials. Required for the kubernetes/helm providers:
# with managed AAD + Azure RBAC enabled, kube_config[0] has empty client cert/key
# (token auth), so provider auth fails. kube_admin_config is populated because
# local accounts are not disabled.
output "kube_admin_config" {
  value     = azurerm_kubernetes_cluster.this.kube_admin_config[0]
  sensitive = true
}

output "kube_config_raw" {
  value     = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive = true
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.this.node_resource_group
}
