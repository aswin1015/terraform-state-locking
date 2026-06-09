variable "resource_group_name" {
  description = "Azure resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "name" {
  description = "Azure AI Document Intelligence (Form Recognizer) account name."
  type        = string
}

variable "sku_name" {
  description = "Pricing tier. Use 'F0' for free (1 per subscription) or 'S0' for standard."
  type        = string
  default     = "S0"
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the private endpoint."
  type        = string
}

variable "vnet_id" {
  description = "Virtual network ID for private DNS zone link."
  type        = string
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
