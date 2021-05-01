
# This optional step enables SSH access to the instances of the virtual machine scale set by using a jumpbox.
#
# Add the following resources to your existing deployment:
#
# - A network interface connected to the same subnet as the virtual machine scale set
# - A virtual machine with this network interface

resource "azurerm_public_ip" "devs_vmss_jumpbox" {
  name                         = "devs-vmss-jumpbox-public-ip"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.devs_vmss_vmss.name
  allocation_method            = "Static"
  domain_name_label            = "${azurerm_resource_group.devs_vmss.name}-ssh"

  tags = {
    environment = "devs"
  }
}

resource "azurerm_network_interface" "devs_vmss_jumpbox" {
  name                = "devs-vmss-jumpbox-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.devs_vmss.name

  ip_configuration {
    name                          = "IPConfiguration"
    subnet_id                     = azurerm_subnet.devs_vmss.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.devs_vmss_jumpbox.id
  }

  tags = {
    environment = "devs"
  }
}

resource "azurerm_virtual_machine" "jumpbox" {
  name                  = "devs-vmss-jumpbox"
  location              = var.location
  resource_group_name   = azurerm_resource_group.devs_vmss.name
  network_interface_ids = [azurerm_network_interface.devs_vmss_jumpbox.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "devs-vmss-jumpbox-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "devs-vmss-jumpbox"
    admin_username = "azureuser"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  tags = {
    environment = "devs"
  }
}