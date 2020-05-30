resource "azurerm_resource_group" "dev-cus-k8s-controllers-rg" {
  name     = "dev-cus-k8s-controllers-rg"
  location = "centralus"

  tags = {
    environment = "dev"
    managed-by = "terraform"
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "k8s-controllers" {
  name                = "k8s-controllers-vmss"
  resource_group_name = azurerm_resource_group.dev-cus-k8s-controllers-rg.name
  location            = azurerm_resource_group.dev-cus-k8s-controllers-rg.location
  sku                 = "Standard_B2s"
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
    environment = "dev"
    managed-by = "terraform"
    role = "controller"
  }
}
