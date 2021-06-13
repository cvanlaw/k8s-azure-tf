resource "azurerm_resource_group" "dev-cus-k8s-workers-rg" {
  name     = "dev-cus-k8s-workers-rg"
  location = "centralus"

  tags = {
    environment = var.environment
    managed-by = "terraform"
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "k8s-workers" {
  name                = "k8s-workers-vmss"
  resource_group_name = azurerm_resource_group.dev-cus-k8s-workers-rg.name
  location            = azurerm_resource_group.dev-cus-k8s-workers-rg.location
  sku                 = "Standard_B4ms"
  instances           = 3
  admin_username      = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    disk_size_gb         = 200
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.k8s-subnet.id
    }
  }

  tags = {
    environment = var.environment
    managed-by = "terraform"
    role = "worker"
  }
}
