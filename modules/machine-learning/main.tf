resource "azurerm_machine_learning_workspace" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku_name = var.sku_name

  application_insights_id = var.application_insights_id
  key_vault_id             = var.key_vault_id
  storage_account_id       = var.storage_account_id

  # System storage access goes through this workspace's managed identity,
  # not an account key — the storage module has shared_access_key_enabled
  # = false, so "AccessKey" mode wouldn't work here anyway.
  storage_account_access_type = "Identity"

  public_network_access_enabled = false

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
