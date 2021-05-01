
#######################################################################################
#### STAGE A 0.1 - Create VMs
#######################################################################################

data "azurerm_image" "image" {
  name                = "myPackerImage"
  resource_group_name = data.azurerm_resource_group.ops.name
}

resource "azurerm_virtual_machine_scale_set" "devs_vmss" {
  name                = "devs-vmss"
  location            = var.location
  resource_group_name = azurerm_resource_group.devs_vmss.name
  upgrade_policy_mode = "Manual"

  sku {
    name     = "Standard_B1ls"
    tier     = "Standard"
    capacity = 1
  }

  storage_profile_image_reference {
    id=data.azurerm_image.image.id
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun          = 0
    caching        = "ReadWrite"
    create_option  = "Empty"
    disk_size_gb   = 10
  }

  os_profile {
    computer_name_prefix = "vmlab"
    admin_username       = "azureuser"
    admin_password       = "Passwword1234"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = azurerm_subnet.devs_vmss.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.devs_vmss_bpepool.id]
      primary = true
    }
  }
  
  tags = {
    environment = "devs"
  }
}