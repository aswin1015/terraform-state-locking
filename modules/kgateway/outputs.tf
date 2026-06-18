output "kgateway_namespace" {
  value = helm_release.kgateway.namespace
}

output "kgateway_status" {
  value = helm_release.kgateway.status
}
