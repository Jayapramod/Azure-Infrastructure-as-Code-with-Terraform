output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "public_subnet_id" {
  value = azurerm_subnet.public.id
}

output "private_subnet_id" {
  value = azurerm_subnet.private.id
}

output "public_nsg_id" {
  value = azurerm_network_security_group.public_nsg.id
}

output "private_nsg_id" {
  value = azurerm_network_security_group.private_nsg.id
}

output "nat_gateway_id" {
  value = azurerm_nat_gateway.this.id
}

output "nat_public_ip_id" {
  value = azurerm_public_ip.nat_pip.id
}

output "appgw_subnet_id" {
  value = length(var.appgw_subnet_prefix) > 0 ? azurerm_subnet.appgw[0].id : ""
}
