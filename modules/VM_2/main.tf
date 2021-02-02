
# Create virtual network
resource "azurerm_virtual_network" "mainVNET" {
    name                = "${var.prefix}-VNET2"
    address_space       = ["10.0.2.0/24"]
    location            = var.location
    resource_group_name = var.rgs

    tags = {
        environment = var.tags
    }
}

# Create subnet
resource "azurerm_subnet" "mainSubnet" {
    name                 = "subnet1"
    resource_group_name  = var.rgs
    virtual_network_name = azurerm_virtual_network.mainVNET.name
    address_prefixes       = ["10.0.2.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "mainPublicip" {
    count                        = var.counter
    name                         = "${var.prefix}-publicIP-${format("%01d", count.index)}"
    location                     = var.location
    resource_group_name          = var.rgs
    allocation_method            = var.IPallocationMethod

    tags = {
        environment = var.tags
    }
}

# Getting Security Group 

data "azurerm_application_security_group" "existingsecuritygroup" {
  name                = "segGroupVM1"
  resource_group_name = var.rgs
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "mainNSG" {
    name                = "${var.prefix}-NSG2"
    location            = var.location
    resource_group_name = var.rgs

    security_rule {
        name                       = "HTTPS"
        priority                   = 300
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

   security_rule {
        name                       = "AllowVM0"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_application_security_group_ids  = [data.azurerm_application_security_group.existingsecuritygroup.id]
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "DenyAllAgain"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }


    tags = {
        environment = var.tags
    }
}

# Create network interface
resource "azurerm_network_interface" "mainNic" {
    count                     = var.counter
    name                      = "${var.prefix}-NIC${format("%01d", count.index)}"
    location                  = var.location
    resource_group_name       = var.rgs

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.mainSubnet.id
        private_ip_address_allocation = var.NICAIPallocationMethod
        public_ip_address_id = element(azurerm_public_ip.mainPublicip.*.id, count.index)
    }

    tags = {
        environment = var.tags
    }
}

# Subnet and NSG association
resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
subnet_id = azurerm_subnet.mainSubnet.id
network_security_group_id = azurerm_network_security_group.mainNSG.id
}


# Create (and display) an SSH key
resource "tls_private_key" "sshkey" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "mainVM" {
    count                 = var.counter
    name                  = "${var.vmname2}-${format("%01d", count.index)}"
    location              = var.location
    resource_group_name   = var.rgs
    network_interface_ids = [element(azurerm_network_interface.mainNic.*.id, count.index)]
    size                  = var.vmsize

    os_disk {
        name              = "myosdisk-${count.index}"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  =  "${var.vmname2}-${format("%01d", count.index)}"
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
