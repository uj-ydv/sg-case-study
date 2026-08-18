resource "azurerm_container_registry" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                  = var.sku

  # No admin credentials — pulls go through managed identity + AcrPull RBAC only.
  admin_enabled = false

  public_network_access_enabled = false

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
