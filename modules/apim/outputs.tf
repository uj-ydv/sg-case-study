output "id" {
  value = azurerm_api_management.this.id
}

output "name" {
  value = azurerm_api_management.this.name
}

output "gateway_url" {
  value = azurerm_api_management.this.gateway_url
}

# Feeds modules/app-gateway's apim_gateway_hostname variable — the backend
# pool FQDN, Host header and probe host all resolve to this.
output "gateway_hostname" {
  value = coalesce(var.custom_domain_name, trimprefix(azurerm_api_management.this.gateway_url, "https://"))
}

output "private_ip_addresses" {
  value = azurerm_api_management.this.private_ip_addresses
}

output "system_assigned_principal_id" {
  value = azurerm_api_management.this.identity[0].principal_id
}
