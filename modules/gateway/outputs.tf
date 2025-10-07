output "public_ip_id" {
  value = azurerm_public_ip.this.id
}

output "application_gateway_id" {
  value = azurerm_application_gateway.this.id
}

output "key_vault_id" {
  value = azurerm_key_vault.this.id
}

output "certificate_secret_id" {
  value = azurerm_key_vault_certificate.this.secret_id
}

output "appgw_user_assigned_identity_id" {
  value = azurerm_user_assigned_identity.appgw_identity.id
}

output "appgw_user_assigned_identity_principal_id" {
  value = azurerm_user_assigned_identity.appgw_identity.principal_id
}
