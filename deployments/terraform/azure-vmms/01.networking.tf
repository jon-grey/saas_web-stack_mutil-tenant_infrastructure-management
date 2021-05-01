
#######################################################################################
#### STAGE A 0.1 - Create Networking
#######################################################################################

resource "azurerm_virtual_network" "devs_vmss" {
  name                = "devs-vmss-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.devs_vmss.name

  tags = {
    environment = "devs"
  }
}

resource "azurerm_subnet" "devs_vmss" {
  name                 = "devs-vmss-subnet"
  resource_group_name  = azurerm_resource_group.devs_vmss.name
  virtual_network_name = azurerm_virtual_network.devs_vmss.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "devs_vmss" {
  name                         = "devs-vmss-public-ip"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.devs_vmss.name
  allocation_method            = "Static"
  domain_name_label            = azurerm_resource_group.devs_vmss.name

  tags = {
    environment = "devs"
  }
}


resource "azurerm_lb" "devs_vmss" {
  name                = "devs-vmss-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.devs_vmss.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.devs_vmss.id
  }

  tags = {
    environment = "devs"
  }
}

resource "azurerm_lb_backend_address_pool" "devs_vmss_bpepool" {
  resource_group_name = azurerm_resource_group.devs_vmss.name
  loadbalancer_id     = azurerm_lb.devs_vmss.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "devs_vmss" {
  resource_group_name = azurerm_resource_group.devs_vmss.name
  loadbalancer_id     = azurerm_lb.devs_vmss.id
  name                = "ssh-running-probe"
  port                = var.application_port
}

resource "azurerm_lb_rule" "lbnatrule" {
  resource_group_name            = azurerm_resource_group.devs_vmss.name
  loadbalancer_id                = azurerm_lb.devs_vmss.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = var.application_port
  backend_port                   = var.application_port
  backend_address_pool_id        = azurerm_lb_backend_address_pool.devs_vmss_bpepool.id
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.devs_vmss.id
}