locals {
  common_tags = merge(var.tags, {
    environment = var.environment
    workload    = var.workload_name
  })

  container_apps = {
    "api-gateway" = {
      image            = "${var.container_registry_server}/aegis-api-gateway:${var.container_image_version}"
      target_port      = 5000
      external_enabled = true
      min_replicas     = 1
      max_replicas     = 3
      cpu              = 0.5
      memory           = "1Gi"
      env = {
        PORT = "5000"
      }
      secrets = {
        MONGODB_URI = module.cosmosdb.mongodb_connection_string
        JWT_SECRET  = var.jwt_secret
      }
    }
    "notification-worker" = {
      image            = "${var.container_registry_server}/aegis-notification-worker:${var.container_image_version}"
      target_port      = null
      external_enabled = false
      min_replicas     = 1
      max_replicas     = 2
      cpu              = 0.5
      memory           = "1Gi"
      env              = {}
      secrets = {
        MONGODB_URI = module.cosmosdb.mongodb_connection_string
      }
    }
    client = {
      image            = "${var.container_registry_server}/aegis-client:${var.container_image_version}"
      target_port      = 80
      external_enabled = true
      min_replicas     = 1
      max_replicas     = 3
      cpu              = 0.5
      memory           = "1Gi"
      env              = {}
      secrets          = {}
    }
  }
}

module "resource_group" {
  source = "./modules/resource-group"

  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "networking" {
  source = "./modules/networking"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vnet_name           = var.vnet_name
  address_space       = var.vnet_address_space
  subnets             = var.subnets
  tags                = local.common_tags
}

module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  workspace_name      = "${var.workload_name}-${var.environment}-law"
  tags                = local.common_tags
}

module "cosmosdb" {
  source = "./modules/cosmosdb"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  account_name        = var.cosmosdb_account_name
  database_name       = var.cosmosdb_database_name
  subnet_id           = module.networking.subnet_ids["pe-subnet"]
  vnet_id             = module.networking.vnet_id
  tags                = local.common_tags
}

module "storage" {
  source = "./modules/storage"

  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  account_name_prefix        = var.storage_account_name_prefix
  container_names            = var.storage_container_names
  private_endpoint_subnet_id = module.networking.subnet_ids["pe-subnet"]
  vnet_id                    = module.networking.vnet_id
  tags                       = local.common_tags
}

module "doc_intelligence" {
  source = "./modules/doc-intelligence"

  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  name                       = var.doc_intelligence_name
  private_endpoint_subnet_id = module.networking.subnet_ids["pe-subnet"]
  vnet_id                    = module.networking.vnet_id
  tags                       = local.common_tags
}

module "communication" {
  source = "./modules/communication"

  resource_group_name        = module.resource_group.name
  location                   = "global"
  communication_service_name = var.communication_service_name
  email_service_name         = var.email_service_name
  email_domain_name          = var.email_domain_name
  domain_management          = var.email_domain_management
  tags                       = local.common_tags
}

module "function_app" {
  source = "./modules/function-app"

  resource_group_name              = module.resource_group.name
  location                         = module.resource_group.location
  name                             = var.function_app_name
  storage_account_name             = module.storage.account_name
  storage_account_access_key       = module.storage.primary_access_key
  storage_connection_string        = module.storage.primary_connection_string
  cosmosdb_connection_string       = module.cosmosdb.mongodb_connection_string
  communication_service_connection = module.communication.primary_connection_string
  acs_sender_address               = var.acs_sender_address
  form_recognizer_endpoint         = module.doc_intelligence.endpoint
  form_recognizer_key              = module.doc_intelligence.primary_key
  vnet_integration_subnet_id       = module.networking.subnet_ids["function-subnet"]
  private_endpoint_subnet_id       = module.networking.subnet_ids["pe-subnet"]
  vnet_id                          = module.networking.vnet_id
  tags                             = local.common_tags
}

module "container_apps" {
  source = "./modules/container-apps"

  resource_group_name            = module.resource_group.name
  location                       = module.resource_group.location
  environment_name               = "${var.workload_name}-${var.environment}-env"
  log_analytics_workspace_id     = module.monitoring.workspace_id
  log_analytics_workspace_key    = module.monitoring.primary_shared_key
  infrastructure_subnet_id       = module.networking.subnet_ids["container-app-env"]
  internal_load_balancer_enabled = true
  container_registry_server      = var.container_registry_server
  container_registry_username    = var.container_registry_username
  container_registry_password    = var.container_registry_password
  apps                           = local.container_apps
  tags                           = local.common_tags
}

module "app_gateway" {
  source = "./modules/app-gateway"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = var.app_gateway_name
  subnet_id           = module.networking.subnet_ids["appgtw-subnet"]
  backend_fqdn        = module.container_apps.app_fqdns[var.app_gateway_backend_app_name]
  backend_host_name   = module.container_apps.app_fqdns[var.app_gateway_backend_app_name]
  tags                = local.common_tags
}
