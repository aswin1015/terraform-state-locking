environment               = "dev"
resource_group_name       = "app-rg-dev"
location                  = "Central India"
container_image_version   = "v1.0.6"
container_registry_server = "insurancecr.azurecr.io"
jwt_secret                = "MyInsuranceJwtSecret2026"

cosmosdb_account_name       = "health-csdb-dev"
storage_account_name_prefix = "healthstoragedev"
function_app_name           = "health-fun-dev"
communication_service_name  = "healthcs-dev"
email_service_name          = "health-email-dev"
app_gateway_name            = "appgtw-dev"

email_domain_name       = "AzureManagedDomain"
email_domain_management = "AzureManaged"

tags = {
  owner = "platform"
}
