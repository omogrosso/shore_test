data "azurerm_virtual_network" "mainvnet1" {
  name                = var.vnet1
  resource_group_name = var.rgs
}

output "virtual_network_id" {
  value = data.azurerm_virtual_network.mainvnet1.id
}

data "azurerm_virtual_network" "mainvnet2" {
  name                = var.vnet2
  resource_group_name = var.rgs
}

output "virtual_network_id2" {
  value = data.azurerm_virtual_network.mainvnet2.id
}

resource "azurerm_virtual_network_peering" "peerVNET1" {
  name                      = "peer1to2"
  resource_group_name       = var.rgs
  virtual_network_name      = data.azurerm_virtual_network.mainvnet1.name
  remote_virtual_network_id = data.azurerm_virtual_network.mainvnet2.id
}

resource "azurerm_virtual_network_peering" "peerVNET2" {
  name                      = "peer2to1"
  resource_group_name       = var.rgs
  virtual_network_name      = data.azurerm_virtual_network.mainvnet2.name
  remote_virtual_network_id = data.azurerm_virtual_network.mainvnet1.id
}