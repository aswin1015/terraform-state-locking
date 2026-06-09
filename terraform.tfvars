environment               = "dev"
resource_group_name       = "app-rg"
location                  = "Central India"
container_image_version   = "v1.0.6"
container_registry_server = "insurancecr.azurecr.io"

# Set with TF_VAR_jwt_secret or replace this placeholder before apply.
jwt_secret = "MyInsuranceJwtSecret2026"

# For private ACR pulls, set these with TF_VAR_container_registry_username/password.
# container_registry_username = "insurancecr"
# container_registry_password = "..."

email_domain_name       = "AzureManagedDomain"
email_domain_management = "AzureManaged"

tags = {
  owner = "platform"
}
