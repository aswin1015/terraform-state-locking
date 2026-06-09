variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "subnets" {
  type = map(object({
    address_prefixes   = list(string)
    delegation_name    = optional(string)
    delegation_service = optional(string)
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}
