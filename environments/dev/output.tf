output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}

output "vm_private_ips" {
  value = module.compute.private_ips
}

output "appgw_public_ip" {
  value = module.gateway.public_ip_id
}
