# Granted to the project's identity — that's what agents/tools actually
# authenticate as at runtime, distinct from the account-level identity that
# governs the Cognitive Services resource itself.

resource "azurerm_role_assignment" "key_vault_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_cognitive_account_project.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_cognitive_account_project.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_cognitive_account_project.this.identity[0].principal_id
}
