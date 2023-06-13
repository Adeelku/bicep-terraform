locals {
  name = var.prefix
  location = var.region
  vm_size = var.env == "prod" ? "Standard_D2ds_v4" : "Standard_B2ms"
  vm_storage_type = var.env == "prod" ? "Premium_GRS" : "Standard_LRS"
}

resource "azurerm_resource_group" "vm_rg" {
  name     = "${local.name}-vm-rg"
  location = local.location
}

resource "azurerm_resource_group" "vnet_rg" {
  name     = "${local.name}-vnet-rg"
  location = local.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.name}-vnet"
  location            = azurerm_resource_group.vnet_rg.location
  resource_group_name = azurerm_resource_group.vnet_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet_vms" {
  name                 = "${local.name}-vms-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.vnet_rg.name
  address_prefixes     = ["10.0.7.0/24"]
}


resource "azurerm_network_interface" "vm_nic" {
  name                = "${local.name}-nic"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_vms.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vm_pip.id
  }
  
}

resource "azurerm_public_ip" "vm_pip" {
  name                = "${local.name}-pip"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name
  allocation_method   = "Dynamic"
  sku = "Basic"

}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name
  size                = local.vm_size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
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
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
