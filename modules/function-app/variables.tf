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

variable "storage_connection_string" {
  description = "Full connection string for the storage account (used by the blob trigger binding)."
  type        = string
  sensitive   = true
}

variable "cosmosdb_connection_string" {
  type      = string
  sensitive = true
}

variable "communication_service_connection" {
  type      = string
  sensitive = true
}

variable "acs_sender_address" {
  description = "Sender address for Azure Communication Services email (e.g. DoNotReply@<domain>.azurecomm.net)."
  type        = string
}

variable "form_recognizer_endpoint" {
  description = "Endpoint URL for Azure AI Document Intelligence (Form Recognizer)."
  type        = string
}

variable "form_recognizer_key" {
  description = "Primary access key for Azure AI Document Intelligence."
  type        = string
  sensitive   = true
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

