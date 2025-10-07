resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
}

resource "azurerm_subnet" "public" {
  name                 = var.public_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.public_subnet_prefix]
}

resource "azurerm_subnet" "private" {
  name                 = var.private_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.private_subnet_prefix]
}

resource "azurerm_subnet" "appgw" {
  count                = var.appgw_subnet_prefix != "" ? 1 : 0
  name                 = var.appgw_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.appgw_subnet_prefix]
}

resource "azurerm_network_security_group" "public_nsg" {
  name                = var.public_nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "private_nsg" {
  name                = var.private_nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Deny direct SSH from Internet
  security_rule {
    name                       = "Deny-SSH-Internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow SSH from the public subnet (bastion / jumpbox)
  security_rule {
    name                       = "Allow-SSH-From-PublicSubnet"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.public_subnet_prefix
    destination_address_prefix = "*"
  }

  # Allow HTTP from Application Gateway (assumed in public subnet)
  security_rule {
    name                       = "Allow-HTTP-From-AppGateway"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    # Allow traffic from both the public subnet (bastion/appgw) and the appgw subnet
    # so Application Gateway health probes and traffic can reach the private VMs.
    source_address_prefixes    = [var.public_subnet_prefix, var.appgw_subnet_prefix]
    destination_address_prefix = "*"
  }

  # Allow HTTPS from Application Gateway
  security_rule {
    name                       = "Allow-HTTPS-From-AppGateway"
    priority                   = 310
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = [var.public_subnet_prefix, var.appgw_subnet_prefix]
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.public_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.private_nsg.id
}

# Public IP for NAT Gateway
resource "azurerm_public_ip" "nat_pip" {
  name                = var.nat_public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "this" {
  name                = var.nat_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "Standard"

  tags = var.tags
}


# Associate the public IP with the NAT Gateway (azurerm v3 uses separate association resource)
resource "azurerm_nat_gateway_public_ip_association" "nat_pubip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.nat_pip.id
}

resource "azurerm_subnet_nat_gateway_association" "private_assoc" {
  subnet_id      = azurerm_subnet.private.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}
