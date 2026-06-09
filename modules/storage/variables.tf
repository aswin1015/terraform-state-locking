variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "account_name_prefix" {
  type = string
}

variable "container_names" {
  type    = set(string)
  default = []
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
