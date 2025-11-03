terraform {
  backend "azurerm" {
    resource_group_name  = "Jayrg"
    storage_account_name = "jaystorageaccount05"
    container_name      = "tfstate"
    key                = "dev.tfstate"
    use_azuread_auth   = true
    use_oidc           = false
  }
}
