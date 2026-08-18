resource "azurerm_cosmosdb_account" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  offer_type = "Standard"
  kind       = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = var.consistency_level
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  public_network_access_enabled = false

  # Data plane access is Entra ID + RBAC only — primary/secondary keys disabled.
  local_authentication_disabled = true

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
