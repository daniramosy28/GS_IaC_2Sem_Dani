resource "azurerm_virtual_network" "vnet" {
  name                = "staticsite-vm-vnet-dani"
  location            = "${var.location}"
  resource_group_name = "${var.rg_name}"
  address_space       = ["${var.vnet_cidr}"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "staticsite-vm-subnet-dani"
  resource_group_name  = "${var.rg_name}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.subnet_cidr}"]
}