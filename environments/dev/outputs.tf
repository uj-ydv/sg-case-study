output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "key_vault_uri" {
  value = module.key_vault.uri
}

output "storage_account_name" {
  value = module.storage.name
}

output "cosmosdb_endpoint" {
  value = module.cosmosdb.endpoint
}

output "container_registry_login_server" {
  value = module.container_registry.login_server
}

output "app_service_default_hostname" {
  value = module.app_service.default_hostname
}

output "ai_foundry_endpoint" {
  value = module.ai_foundry.endpoint
}

output "apim_gateway_url" {
  value = module.apim.gateway_url
}

output "app_gateway_public_ip" {
  value = module.app_gateway.public_ip_address
}
