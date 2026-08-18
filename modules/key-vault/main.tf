resource "azurerm_key_vault" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id
  sku_name            = var.sku_name

  # RBAC only — no access policies, no standing per-object grants.
  enable_rbac_authorization = true

  purge_protection_enabled   = true
  soft_delete_retention_days = var.soft_delete_retention_days

  public_network_access_enabled = false

  network_acls {
    default_action = "Deny"
    bypass          = "AzureServices"
  }

  tags = var.tags
}
