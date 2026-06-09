environment               = "test"
resource_group_name       = "app-rg-test"
location                  = "Central India"
container_image_version   = "v1.0.6"
container_registry_server = "insurancecr.azurecr.io"
jwt_secret                = "MyInsuranceJwtSecret2026"

cosmosdb_account_name       = "health-csdb-test"
storage_account_name_prefix = "healthstoragetest"
function_app_name           = "health-fun-test"
communication_service_name  = "healthcs-test"
email_service_name          = "health-email-test"
app_gateway_name            = "appgtw-test"

email_domain_name       = "AzureManagedDomain"
email_domain_management = "AzureManaged"

tags = {
  owner = "platform"
}
