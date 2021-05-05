


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


resource "azurerm_dns_zone" "zone" {
  name                = var.az_custom_domain
  resource_group_name = var.az_resource_group_name
  depends_on = [
      azurerm_public_ip.this,
  ]

}

resource "azurerm_dns_zone" "subzone" {
  name                = "azure.${var.az_custom_domain}"
  resource_group_name = var.az_resource_group_name
  depends_on = [
      azurerm_dns_zone.zone,
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

resource "azurerm_dns_a_record" "zone_root" {
  name                = "@"
  zone_name           = azurerm_dns_zone.zone.name
  resource_group_name = var.az_resource_group_name
  ttl = 300

  records = [azurerm_public_ip.this.ip_address]


  depends_on = [
      azurerm_dns_zone.zone,
  ]

}

resource "azurerm_dns_a_record" "subzone_root" {
  name                = "@"
  zone_name           = azurerm_dns_zone.subzone.name
  resource_group_name = var.az_resource_group_name
  ttl = 300

  records = [azurerm_public_ip.this.ip_address]


  depends_on = [
      azurerm_dns_zone.subzone,
  ]

}


resource "azurerm_dns_a_record" "subzone_all" {
  name                = "*"
  zone_name           = azurerm_dns_zone.subzone.name
  resource_group_name = var.az_resource_group_name
  ttl = 300

  records = [azurerm_public_ip.this.ip_address]


  depends_on = [
      azurerm_dns_zone.subzone,
  ]

}