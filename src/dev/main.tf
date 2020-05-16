provider "azurerm" {
  version = "~>2.0"
  # use_msi = true

  features {}
}

terraform {
  backend "azurerm" {
    storage_account_name = "tstate29629"
    container_name       = "tstate"
    key                  = "terraform.tfstate"
    resource_group_name  = "tstate"
  }
}
