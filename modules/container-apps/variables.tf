variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment_name" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "log_analytics_workspace_key" {
  type      = string
  sensitive = true
}

variable "infrastructure_subnet_id" {
  type = string
}

variable "internal_load_balancer_enabled" {
  type    = bool
  default = true
}

variable "container_registry_server" {
  type = string
}

variable "container_registry_username" {
  type      = string
  default   = null
  sensitive = true
}

variable "container_registry_password" {
  type      = string
  default   = null
  sensitive = true
}

variable "apps" {
  type = map(object({
    image            = string
    target_port      = optional(number)
    external_enabled = bool
    min_replicas     = number
    max_replicas     = number
    cpu              = number
    memory           = string
    env              = map(string)
    secrets          = map(string)
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}
