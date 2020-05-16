provider "azurerm" {
    version = "~>2.0"
    # use_msi = true

    features {}
}

terraform {
  backend "azurerm" {
    storage_account_name  = "tstate29629"
    container_name        = "tstate"
    key                   = "terraform.tfstate"
    resource_group_name   = "tstate"
  }
}

resource "azurerm_resource_group" "dev-cus-networking-rg" {
    name     = "dev-cus-networking-rg"
    location = "centralus"

    tags = {
        environment = "dev"
    }
}

resource "azurerm_virtual_network" "dev-cus-vnet" {
    name                = "dev-cus-vnet"
    address_space       = ["10.20.0.0/20"]
    location            = "centralus"
    resource_group_name = azurerm_resource_group.dev-cus-networking-rg.name

    tags = {
        environment = "dev"
    }
}

resource "azurerm_subnet" "k8s-subnet" {
    name                 = "k8s"
    resource_group_name  = azurerm_resource_group.dev-cus-networking-rg.name
    virtual_network_name = azurerm_virtual_network.dev-cus-vnet.name
    address_prefixes       = [ "10.20.2.0/24" ]
}

resource "azurerm_subnet" "jump-subnet" {
    name                 = "jump"
    resource_group_name  = azurerm_resource_group.dev-cus-networking-rg.name
    virtual_network_name = azurerm_virtual_network.dev-cus-vnet.name
    address_prefixes       = [ "10.20.1.0/24" ]
}

resource "azurerm_network_security_group" "k8s-subnet-nsg" {
    name                = "k8s-subnet-nsg"
    location            = "centralus"
    resource_group_name = azurerm_resource_group.dev-cus-networking-rg.name
    
    security_rule {
        name                       = "Internal_Allow_SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.20.0.0/20"
        destination_address_prefix = "10.20.0.0/20"
    }

    security_rule {
        name                       = "Internal_Allow_ICMP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "ICMP"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.20.0.0/20"
        destination_address_prefix = "10.20.0.0/20"
    }

    security_rule {
        name                       = "Internal_Allow_6443"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "6443"
        source_address_prefix      = "10.20.0.0/20"
        destination_address_prefix = "10.20.0.0/20"
    }

    tags = {
        environment = "dev"
    }
}

resource "azurerm_network_security_group" "jump-subnet-nsg" {
    name                = "jump-subnet-nsg"
    location            = "centralus"
    resource_group_name = azurerm_resource_group.dev-cus-networking-rg.name
    
    security_rule {
        name                       = "Internal_Allow_SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.20.0.0/20"
        destination_address_prefix = "10.20.0.0/20"
    }

    security_rule {
        name                       = "External_Allow_SSH"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "10.20.1.0/24"
    }

    security_rule {
        name                       = "Internal_Allow_ICMP"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "ICMP"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.20.0.0/20"
        destination_address_prefix = "10.20.0.0/20"
    }

    security_rule {
        name                       = "Internal_Allow_6443"
        priority                   = 1004
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "6443"
        source_address_prefix      = "10.20.0.0/20"
        destination_address_prefix = "10.20.0.0/20"
    }

    tags = {
        environment = "dev"
    }
}

resource "azurerm_subnet_network_security_group_association" "k8s-nsg" {
  subnet_id                 = azurerm_subnet.k8s-subnet.id
  network_security_group_id = azurerm_network_security_group.k8s-subnet-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "jump-nsg" {
  subnet_id                 = azurerm_subnet.jump-subnet.id
  network_security_group_id = azurerm_network_security_group.jump-subnet-nsg.id
}

resource "azurerm_public_ip" "jump-public-ip" {
  name                = "jump-public-ip"
  location            = "Central US"
  resource_group_name = azurerm_resource_group.dev-cus-networking-rg.name
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "jump-nic" {
  name                = "jump-box-nic"
  location            = azurerm_resource_group.dev-cus-networking-rg.location
  resource_group_name = azurerm_resource_group.dev-cus-networking-rg.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.jump-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.jump-public-ip.id
  }

  # ip_configuration {
  #     name = "external"
  #     public_ip_address_id = azurerm_public_ip.jump-public-ip.id
  # }
}

resource "azurerm_linux_virtual_machine" "jump-box" {
  name                = "jump-box"
  resource_group_name = azurerm_resource_group.dev-cus-networking-rg.name
  location            = azurerm_resource_group.dev-cus-networking-rg.location
  size                = "Standard_F2"
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
    sku       = "16.04-LTS"
    version   = "latest"
  }
}