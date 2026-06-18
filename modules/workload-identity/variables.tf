variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "identity_name" {
  type = string
}

variable "aks_oidc_issuer_url" {
  type = string
}

variable "k8s_namespace" {
  type = string
}

variable "k8s_service_account" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
