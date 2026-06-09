variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "backend_fqdn" {
  type = string
}

variable "backend_host_name" {
  type = string
}

variable "health_probe_path" {
  type    = string
  default = "/"
}

variable "tags" {
  type    = map(string)
  default = {}
}
