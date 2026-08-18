# container_registry_id is deliberately NOT wired into the workspace
# resource itself: azurerm_machine_learning_workspace only accepts that link
# when the registry has admin_enabled = true, which conflicts with this
# platform's "no admin credentials" control on Container Registry (see
# modules/container-registry). Instead the workspace's own identity pulls
# base images and pushes built training/inference environments via RBAC,
# same pattern as every other consumer.

resource "azurerm_role_assignment" "key_vault_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_machine_learning_workspace.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_machine_learning_workspace.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_machine_learning_workspace.this.identity[0].principal_id
}

# ML workspaces build custom environments and push them back to the
# registry, unlike the other consumers which only ever pull.
resource "azurerm_role_assignment" "acr_push" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_machine_learning_workspace.this.identity[0].principal_id
}
