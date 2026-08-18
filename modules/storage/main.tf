resource "azurerm_storage_account" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  public_network_access_enabled = false

  # Data plane access is Entra ID + RBAC only — no shared keys handed out.
  shared_access_key_enabled = false

  network_rules {
    default_action = "Deny"
    bypass          = ["AzureServices"]
  }

  tags = var.tags
}

resource "azurerm_storage_container" "documents" {
  name                  = "documents"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}