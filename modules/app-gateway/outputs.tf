output "id" {
  value = azurerm_application_gateway.this.id
}

output "public_ip_address" {
  value = azurerm_public_ip.this.ip_address
}

output "user_assigned_identity_id" {
  value = azurerm_user_assigned_identity.this.id
}
