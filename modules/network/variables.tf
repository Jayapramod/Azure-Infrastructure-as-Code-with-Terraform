variable "resource_group_name" {
  description = "Resource group name where networking resources will be created"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "vnet_name" {
  description = "Virtual Network name"
  type        = string
}

variable "address_space" {
  description = "VNet address space (CIDR)"
  type        = list(string)
}

variable "public_subnet_name" {
  type = string
}

variable "public_subnet_prefix" {
  type = string
}

variable "private_subnet_name" {
  type = string
}

variable "private_subnet_prefix" {
  type = string
}

variable "public_nsg_name" {
  type = string
}

variable "private_nsg_name" {
  type = string
}

variable "nat_gateway_name" {
  type = string
}

variable "nat_public_ip_name" {
  type = string
}

variable "appgw_subnet_name" {
  type    = string
  default = "appgw-subnet"
}

variable "appgw_subnet_prefix" {
  type    = string
  default = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
