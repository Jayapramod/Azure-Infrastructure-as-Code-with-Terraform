variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "public_ip_name" {
  type = string
}

variable "key_vault_name" {
  type = string
}

variable "certificate_secret_name" {
  type    = string
  default = "appgw-cert"
}

variable "common_name" {
  type    = string
  default = "example.local"
}

variable "appgw_name" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "appgw_subnet_id" {
  type    = string
  default = ""
}

variable "capacity" {
  type    = number
  default = 1
}

variable "user_assigned_identity_name" {
  type    = string
  default = "appgw-identity"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "backend_private_ips" {
  description = "Optional list of private IPs to populate the Application Gateway backend pool"
  type        = list(string)
  default     = []
}
