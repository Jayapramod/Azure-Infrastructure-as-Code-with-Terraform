locals {
  env = "prod"
}

module "network" {
  source = "../../modules/network"

  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  vnet_name             = "${var.project_name}-vnet-${local.env}"
  address_space         = var.vnet_cidr
  public_subnet_name    = "public-subnet"
  public_subnet_prefix  = var.public_subnet_prefix
  private_subnet_name   = "private-subnet"
  private_subnet_prefix = var.private_subnet_prefix
  appgw_subnet_name     = "appgw-subnet"
  appgw_subnet_prefix   = "10.1.3.0/24"
  public_nsg_name       = "public-nsg"
  private_nsg_name      = "private-nsg"
  nat_gateway_name      = "natgw-${local.env}"
  nat_public_ip_name    = "natgw-pip-${local.env}"
}

module "bastion" {
  source = "../../modules/bastion"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  public_subnet_id    = module.network.public_subnet_id
  ssh_source_cidr     = "0.0.0.0/0"
  admin_username      = var.admin_username
  vm_size             = var.vm_size
  ssh_public_key      = var.ssh_public_key_path != "" ? file(var.ssh_public_key_path) : ""
  tags = local.common_tags
}

module "compute" {
  source = "../../modules/compute"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  private_subnet_id   = module.network.private_subnet_id
  vm_count            = var.vm_count
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key_path != "" ? file(var.ssh_public_key_path) : ""
  vm_name_prefix      = "appvm"
  tags                = local.common_tags

  user_assigned_identity_id = azurerm_user_assigned_identity.vm_identity.id
  acr_name                  = azurerm_container_registry.acr.name
  acr_repository            = var.acr_repository
  acr_tag                   = var.acr_tag
}

module "gateway" {
  source = "../../modules/gateway"

  resource_group_name     = azurerm_resource_group.rg.name
  location                = var.location
  public_ip_name          = "appgw-pip-${local.env}"
  key_vault_name          = "kv-${var.project_name}-${local.env}"
  certificate_secret_name = "appgw-cert"
  common_name             = "${var.project_name}.local"
  appgw_name              = "appgw-${local.env}"
  public_subnet_id        = module.network.appgw_subnet_id
  capacity                = 1
  tags                    = local.common_tags
  backend_private_ips     = module.compute.private_ips
}
