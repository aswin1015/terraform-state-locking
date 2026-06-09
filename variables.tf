variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "workload_name" {
  description = "Short workload name used in Azure resource names."
  type        = string
  default     = "health"
}

variable "resource_group_name" {
  description = "Azure resource group name."
  type        = string
  default     = "app-rg"
}

variable "location" {
  description = "Azure region for regional resources."
  type        = string
  default     = "Central India"
}

variable "vnet_name" {
  description = "Virtual network name."
  type        = string
  default     = "health-vnet"
}

variable "vnet_address_space" {
  description = "Virtual network address space."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Subnet map keyed by subnet name."
  type = map(object({
    address_prefixes   = list(string)
    delegation_name    = optional(string)
    delegation_service = optional(string)
  }))
  default = {
    "appgtw-subnet" = {
      address_prefixes = ["10.0.10.0/24"]
    }
    "container-app-env" = {
      address_prefixes   = ["10.0.20.0/24"]
      delegation_name    = "container-app-env-delegation"
      delegation_service = "Microsoft.App/environments"
    }
    "pe-subnet" = {
      address_prefixes = ["10.0.30.0/24"]
    }
    "function-subnet" = {
      address_prefixes   = ["10.0.40.0/24"]
      delegation_name    = "function-app-delegation"
      delegation_service = "Microsoft.Web/serverFarms"
    }
  }
}

variable "container_registry_server" {
  description = "Container registry login server."
  type        = string
  default     = "insurancecr.azurecr.io"
}

variable "container_registry_username" {
  description = "Optional registry username when pulling from a private registry."
  type        = string
  default     = null
  sensitive   = true
}

variable "container_registry_password" {
  description = "Optional registry password when pulling from a private registry."
  type        = string
  default     = null
  sensitive   = true
}

variable "container_image_version" {
  description = "Container image tag used by all app images."
  type        = string
  default     = "v1.0.6"
}

variable "jwt_secret" {
  description = "JWT secret for api-gateway."
  type        = string
  sensitive   = true
}

variable "cosmosdb_account_name" {
  description = "Globally unique Cosmos DB account name."
  type        = string
  default     = "health-csdb"
}

variable "cosmosdb_database_name" {
  description = "Cosmos DB Mongo database name."
  type        = string
  default     = "health"
}

variable "storage_account_name_prefix" {
  description = "Lowercase globally unique storage account name. Hyphens are removed and the value is truncated to 24 characters."
  type        = string
  default     = "healthstorageacc"
}

variable "storage_container_names" {
  description = "Blob containers to create."
  type        = set(string)
  default     = ["uploads", "exports"]
}

variable "function_app_name" {
  description = "Globally unique Function App name."
  type        = string
  default     = "health-fun"
}

variable "communication_service_name" {
  description = "Azure Communication Services resource name."
  type        = string
  default     = "healthcs"
}

variable "email_service_name" {
  description = "Email Communication Service resource name."
  type        = string
  default     = "health-email"
}

variable "email_domain_name" {
  description = "Email domain name. Use AzureManagedDomain for an Azure-managed sender domain."
  type        = string
  default     = "AzureManagedDomain"
}

variable "email_domain_management" {
  description = "Email domain management mode: AzureManaged or CustomerManaged."
  type        = string
  default     = "AzureManaged"
}

variable "app_gateway_name" {
  description = "Application Gateway name."
  type        = string
  default     = "appgtw"
}

variable "app_gateway_backend_app_name" {
  description = "Container app name that Application Gateway forwards to."
  type        = string
  default     = "client"
}

variable "tags" {
  description = "Common Azure resource tags."
  type        = map(string)
  default     = {}
}
