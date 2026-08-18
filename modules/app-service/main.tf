resource "azurerm_service_plan" "this" {
  name                = "${var.name}-plan"
  resource_group_name = var.resource_group_name
  location            = var.location

  os_type  = "Linux"
  sku_name = var.service_plan_sku

  tags = var.tags
}

resource "azurerm_linux_web_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id

  https_only = true

  # No public hostname exposure — inbound traffic arrives only through the
  # private endpoint below (fronted by APIM / Application Gateway).
  public_network_access_enabled = false

  # Regional VNet integration: all outbound calls to Key Vault, Storage,
  # Cosmos DB and ACR leave through snet-appsvc and resolve via private DNS.
  virtual_network_subnet_id = var.vnet_integration_subnet_id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on               = true
    vnet_route_all_enabled  = true

    application_stack {
      docker_image_name   = var.container_image_name
      docker_registry_url = "https://${var.container_registry_login_server}"
    }

    # No admin username/password — ACR pulls authenticate as this app's
    # system-assigned identity (granted AcrPull below).
    container_registry_use_managed_identity = true
  }

  app_settings = merge(
    {
      WEBSITES_PORT          = tostring(var.container_port)
      KEY_VAULT_URI           = var.key_vault_uri
      STORAGE_BLOB_ENDPOINT   = var.storage_blob_endpoint
      COSMOS_DB_ENDPOINT      = var.cosmosdb_endpoint
    },
    var.app_settings
  )

  tags = var.tags
}
