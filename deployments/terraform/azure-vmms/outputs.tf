output "resource_group_name" {
  value = azurerm_resource_group.devs_vmss.name
}

output "vmss_public_ip" {
    value = azurerm_public_ip.devs_vmss.fqdn
}

output "jumpbox_public_ip" {
    value = azurerm_public_ip.devs_vmss_jumpbox.fqdn
}