output "bastion_public_ip" {
  value = azurerm_public_ip.bastion_pip.ip_address
}

output "bastion_private_key_pem" {
  value     = var.ssh_public_key == "" ? tls_private_key.generated.private_key_pem : ""
  sensitive = true
}

output "bastion_nic_id" {
  value = azurerm_network_interface.bastion_nic.id
}

output "bastion_vm_id" {
  value = azurerm_linux_virtual_machine.bastion.id
}
