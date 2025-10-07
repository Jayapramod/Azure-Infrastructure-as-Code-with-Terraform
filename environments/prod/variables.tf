variable "project_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_cidr" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "public_subnet_prefix" {
  type = string
}

variable "private_subnet_prefix" {
  type = string
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "vm_count" {
  type    = number
  default = 2
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key (on the machine running Terraform) used to connect to created VMs"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "enable_webapp" {
  description = "When true, Terraform will run the local deploy script to push the Docker app to the first compute VM"
  type        = bool
  default     = false
}

variable "acr_repository" {
  description = "Repository name in ACR for the webapp image (e.g., myapp)"
  type        = string
  default     = "myapp"
}

variable "acr_tag" {
  description = "Tag for the ACR image"
  type        = string
  default     = "latest"
}
