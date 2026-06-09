environment               = "prod"
resource_group_name       = "app-rg-prod"
location                  = "Central India"
container_image_version   = "v1.0.6"
container_registry_server = "insurancecr.azurecr.io"
jwt_secret                = "CHANGE_ME"

cosmosdb_account_name       = "health-csdb-prod"
storage_account_name_prefix = "healthstorageprod"
function_app_name           = "health-fun-prod"
communication_service_name  = "healthcs-prod"
email_service_name          = "health-email-prod"
app_gateway_name            = "appgtw-prod"

email_domain_name       = "AzureManagedDomain"
email_domain_management = "AzureManaged"

tags = {
  owner = "platform"
}
