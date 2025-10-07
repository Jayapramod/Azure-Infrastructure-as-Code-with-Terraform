variable "resource_group_name" {
  description = "Resource group where bastion resources will be created"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet where the bastion NIC will be placed"
  type        = string
}

variable "ssh_source_cidr" {
  description = "CIDR range allowed to SSH to the bastion (e.g., your office IP/CIDR)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "admin_username" {
  description = "Admin username for the bastion VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "Optional SSH public key (openssh). If empty, module generates one and outputs the private key PEM as a sensitive output."
  type        = string
  default     = ""
}

variable "vm_size" {
  description = "Bastion VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "bastion"
}

variable "tags" {
  description = "Tags to apply to created resources"
  type        = map(string)
  default     = {}
}
