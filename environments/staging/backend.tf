terraform {
  backend "azurerm" {
    resource_group_name  = "Jayrg"
    storage_account_name = "jaystorageaccount05"
    container_name       = "tfstate"
    key                  = "staging.terraform.tfstate"
  }
}
