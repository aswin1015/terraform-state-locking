variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "storage_account_access_key" {
  type      = string
  sensitive = true
}

variable "cosmosdb_connection_string" {
  type      = string
  sensitive = true
}

variable "communication_service_connection" {
  type      = string
  sensitive = true
}

variable "service_plan_sku_name" {
  type    = string
  default = "EP1"
}

variable "vnet_integration_subnet_id" {
  type = string
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
