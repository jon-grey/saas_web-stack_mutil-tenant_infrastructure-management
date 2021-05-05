
# TODO move parent zone to different resource group
# TODO optional use providers from different subscription

resource "azurerm_public_ip" "this" {
  name                = "ingressStaticIpName"
  resource_group_name = var.az_resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
  tags = {
    environment = "multistage"
  }
}


resource "azurerm_dns_zone" "parent" {
  # provider            = azurerm.parent
  name                = var.az_custom_domain
  resource_group_name = var.az_resource_group_name
  depends_on = [
      azurerm_public_ip.this,
  ]

}

resource "azurerm_dns_zone" "child" {
  # provider            = azurerm.child
  name                = "azure.${var.az_custom_domain}"
  resource_group_name = var.az_resource_group_name
  depends_on = [
      azurerm_dns_zone.parent,
  ]

}

resource "azurerm_dns_ns_record" "child_parent" {
  # provider            = azurerm.parent
  name                = lower("azure")
  zone_name           = lower(var.az_custom_domain)
  resource_group_name = var.az_resource_group_name
  ttl                 = 300

  records = azurerm_dns_zone.child.name_servers

  depends_on = [
      azurerm_dns_zone.child,
  ]
}

# az network dns record-set a add-record \
#     --resource-group myResourceGroup \
#     --zone-name MY_CUSTOM_DOMAIN \
#     --record-set-name * \
#     --ipv4-address MY_EXTERNAL_IP

# az network dns record-set a add-record \
#      --resource-group "MC_aks-resource-group-demo_aks-cluster-demo-000_germanywestcentral" \
#      --zone-name "lubiewarzywka.pl" \
#      --record-set-name '*' \
#      --ipv4-address "20.79.66.102"

resource "azurerm_dns_a_record" "parent_root" {
  name                = "@"
  zone_name           = azurerm_dns_zone.parent.name
  resource_group_name = var.az_resource_group_name
  ttl = 300

  records = [azurerm_public_ip.this.ip_address]


  depends_on = [
      azurerm_dns_zone.parent,
  ]

}

resource "azurerm_dns_a_record" "child_root" {
  name                = "@"
  zone_name           = azurerm_dns_zone.child.name
  resource_group_name = var.az_resource_group_name
  ttl = 300

  records = [azurerm_public_ip.this.ip_address]


  depends_on = [
      azurerm_dns_zone.child,
  ]

}


resource "azurerm_dns_a_record" "child_all" {
  name                = "*"
  zone_name           = azurerm_dns_zone.child.name
  resource_group_name = var.az_resource_group_name
  ttl = 300

  records = [azurerm_public_ip.this.ip_address]


  depends_on = [
      azurerm_dns_zone.child,
  ]

}