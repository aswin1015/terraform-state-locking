variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "key_vault_name" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "deployer_object_id" {
  type = string
}

variable "workload_identity_object_id" {
  type = string
}

variable "secrets" {
  type      = map(string)
  sensitive = true
  default   = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
