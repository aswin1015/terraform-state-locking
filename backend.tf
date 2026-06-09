terraform {
  backend "azurerm" {
    resource_group_name  = "aswin-rg"
    storage_account_name = "aegishealthstorage"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
