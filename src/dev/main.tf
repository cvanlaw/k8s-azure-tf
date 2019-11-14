provider "azurerm" {
    version = "~>1.36.0"
    use_msi = true
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
    address_prefix       = "10.20.1.0/24"
}

resource "azurerm_network_security_group" "k8s-subnet-nsg" {
    name                = "k8s-subnet-nsg"
    location            = "centralus"
    resource_group_name = azurerm_resource_group.dev-cus-networking-rg.name
    
    security_rule {
        name                       = "Allow_SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "Allow_ICMP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "ICMP"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "Allow_6443"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "6443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "dev"
    }
}