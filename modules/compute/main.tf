resource "tls_private_key" "generated" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  cloud_init = <<-EOF
    #cloud-config
    package_update: true
    packages:
      - apt-transport-https
      - ca-certificates
      - curl
      - gnupg
      - lsb-release
    runcmd:
      - apt-get update -y
      - apt-get install -y docker.io
      - systemctl enable --now docker
      - curl -sL https://aka.ms/InstallAzureCLIDeb | bash
      - for i in $(seq 1 10); do az login --identity && break || sleep 5; done
      - for i in $(seq 1 10); do az acr login -n ${var.acr_name} && break || sleep 5; done
      - docker pull ${var.acr_name}.azurecr.io/${var.acr_repository}:${var.acr_tag}
      - docker run -d --name webapp -p 80:80 ${var.acr_name}.azurecr.io/${var.acr_repository}:${var.acr_tag}
  EOF

  cloud_init_b64 = var.acr_name != "" ? base64encode(trimspace(local.cloud_init)) : null
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.generated.private_key_pem
  filename        = "${path.module}/generated_ssh_private_key.pem"
  file_permission = "0600"
}

resource "azurerm_network_interface" "vm_nic" {
  count               = var.vm_count
  name                = "${var.vm_name_prefix}-nic-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.private_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "${var.vm_name_prefix}-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size

  network_interface_ids = [azurerm_network_interface.vm_nic[count.index].id]

  admin_username = var.admin_username

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key != "" ? var.ssh_public_key : tls_private_key.generated.public_key_openssh
  }

  # Attach identity if provided
  dynamic "identity" {
    for_each = var.user_assigned_identity_id != "" ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = [var.user_assigned_identity_id]
    }
  }

  # Cloud-init to login to ACR using managed identity and run the container
  custom_data = local.cloud_init_b64


  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = var.tags
}

