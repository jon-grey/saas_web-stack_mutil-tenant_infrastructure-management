
output "ip_address" {
  value = azurerm_public_ip.this.ip_address
}

output "azurerm_dns_subzone" {
  value = azurerm_dns_zone.subzone.name
}
