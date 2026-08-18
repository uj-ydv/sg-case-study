# Data-plane access for the app's system-assigned identity. No connection
# strings, no stored keys, no Key Vault access policies — see README.

resource "azurerm_role_assignment" "key_vault_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_web_app.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.this.identity[0].principal_id
}

# Cosmos DB data-plane RBAC is a separate system from control-plane RBAC —
# it uses the account's own SQL role definitions, not azurerm_role_assignment.
resource "azurerm_cosmosdb_sql_role_assignment" "data_contributor" {
  resource_group_name = var.resource_group_name
  account_name         = var.cosmosdb_account_name
  role_definition_id   = "${var.cosmosdb_account_id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id         = azurerm_linux_web_app.this.identity[0].principal_id
  scope                = var.cosmosdb_account_id
}
