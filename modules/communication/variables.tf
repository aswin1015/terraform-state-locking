variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "communication_service_name" {
  type = string
}

variable "email_service_name" {
  type = string
}

variable "email_domain_name" {
  type = string
}

variable "domain_management" {
  type    = string
  default = "AzureManaged"
}

variable "data_location" {
  type    = string
  default = "India"
}

variable "tags" {
  type    = map(string)
  default = {}
}
