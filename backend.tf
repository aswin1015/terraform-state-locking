terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstateexample001"
    container_name       = "tfstate"
    key                  = "health-care.tfstate"
  }
}

