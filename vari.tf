provider "azurerm" {
    features{}

}


resource "azurerm_resource_group" "varg" {
  name     = var.rgname
  location = var.rglocation
}

resource "azurerm_virtual_network" "vavnet" {
  name                = var.vnet1
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.varg.location
  resource_group_name = azurerm_resource_group.varg.name
}

resource "azurerm_subnet" "vasubnet" {
  name                 = var.subnet1
  resource_group_name  = azurerm_resource_group.varg.name
  virtual_network_name = azurerm_virtual_network.vavnet.name
  address_prefixes     = var.subnet_address_space
}

resource "azurerm_network_interface" "main" {
  name                = var.nic1
  location            = azurerm_resource_group.varg.location
  resource_group_name = azurerm_resource_group.varg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.vasubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "testvm" {
  name                  = var.vm1
  location              = azurerm_resource_group.varg.location
  resource_group_name   = azurerm_resource_group.varg.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}