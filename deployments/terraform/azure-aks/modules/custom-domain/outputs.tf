
output "ip_address" {
  value = azurerm_public_ip.this.ip_address
}

output "azurerm_dns_child_zone" {
  value = azurerm_dns_zone.child.name
}
