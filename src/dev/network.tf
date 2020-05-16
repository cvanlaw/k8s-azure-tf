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
  address_prefixes     = ["10.20.2.0/24"]
}

resource "azurerm_subnet" "jump-subnet" {
  name                 = "jump"
  resource_group_name  = azurerm_resource_group.dev-cus-networking-rg.name
  virtual_network_name = azurerm_virtual_network.dev-cus-vnet.name
  address_prefixes     = ["10.20.1.0/24"]
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