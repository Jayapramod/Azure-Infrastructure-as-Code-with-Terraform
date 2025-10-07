output "vm_ids" {
  value = azurerm_linux_virtual_machine.vm[*].id
}

output "nic_ids" {
  value = azurerm_network_interface.vm_nic[*].id
}

output "private_ips" {
  value = [for nic in azurerm_network_interface.vm_nic : nic.ip_configuration[0].private_ip_address]
}

output "generated_private_key_pem" {
  value       = var.ssh_public_key == "" ? tls_private_key.generated.private_key_pem : ""
  description = "When `ssh_public_key` input is empty the module generates an SSH key pair and returns the private key PEM. Only populated when generated."
  sensitive   = true
  depends_on  = [local_file.private_key_pem]
}
