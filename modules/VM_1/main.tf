# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "main" {
  name     = var.rgs
  location = var.location

    tags = {
        environment = var.tags
    }
}

# Create virtual network
resource "azurerm_virtual_network" "mainVNET" {
    name                = "${var.prefix}-VNET"
    address_space       = ["10.0.1.0/24"]
    location            = var.location
    resource_group_name = azurerm_resource_group.main.name

    tags = {
        environment = var.tags
    }
}

# Create subnet
resource "azurerm_subnet" "mainSubnet" {
    name                 = "subnet1"
    resource_group_name  = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.mainVNET.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "mainPublicip" {
    name                         = "${var.prefix}-publicIP"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.main.name
    allocation_method            = var.IPallocationMethod

    tags = {
        environment = var.tags
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "mainNSG" {
    name                = "${var.prefix}-NSG"
    location            = var.location
    resource_group_name = azurerm_resource_group.main.name

    security_rule {
        name                       = "SSH"
        priority                   = 300
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = var.ipsallowed
        destination_address_prefix = "*"
    }

    tags = {
        environment = var.tags
    }
}

# Create network interface
resource "azurerm_network_interface" "mainNic" {
    name                      = "${var.prefix}-NIC"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.main.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.mainSubnet.id
        private_ip_address_allocation = var.NICAIPallocationMethod
        public_ip_address_id          = azurerm_public_ip.mainPublicip.id
    }

    tags = {
        environment = var.tags
    }
}

resource "azurerm_application_security_group" "mainsecuritygroup" {
  name                      = "segGroupVM1"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.main.name

  tags = {
    environment = var.tags
  }
}


# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.mainNic.id
    network_security_group_id = azurerm_network_security_group.mainNSG.id
}


# Create (and display) an SSH key
resource "tls_private_key" "sshkey" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "mainVM" {
    name                  = var.vmname
    location              = var.location
    resource_group_name   = azurerm_resource_group.main.name
    network_interface_ids = [azurerm_network_interface.mainNic.id]
    size                  = var.vmsize

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  =  var.vmname
    admin_username =  var.username
    disable_password_authentication = true

    admin_ssh_key {
        username       = var.username
        public_key     = tls_private_key.sshkey.public_key_openssh
    }
    
#   boot_diagnostics {}

    tags = {
        environment = var.tags
    }
}
