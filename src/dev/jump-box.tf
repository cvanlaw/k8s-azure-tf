resource "azurerm_resource_group" "dev-cus-jump-rg" {
  name     = "dev-cus-jump-rg"
  location = "centralus"

  tags = {
    environment = var.environment
  }
}

resource "azurerm_public_ip" "jump-public-ip" {
  name                = "jump-public-ip"
  location            = "Central US"
  resource_group_name = azurerm_resource_group.dev-cus-networking-rg.name
  allocation_method   = "Static"

  tags = {
    environment = var.environment
  }
}

resource "azurerm_network_interface" "jump-nic" {
  name                = "jump-box-nic"
  location            = azurerm_resource_group.dev-cus-jump-rg.location
  resource_group_name = azurerm_resource_group.dev-cus-jump-rg.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.jump-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jump-public-ip.id
  }
}

resource "azurerm_linux_virtual_machine" "jump-box" {
  name                = "jump-box"
  resource_group_name = azurerm_resource_group.dev-cus-jump-rg.name
  location            = azurerm_resource_group.dev-cus-jump-rg.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.jump-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    environment = var.environment
    managed-by = "terraform"
    role = "jump"
  }
}
