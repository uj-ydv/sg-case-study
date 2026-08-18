resource "azurerm_public_ip" "this" {
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location

  allocation_method = "Static"
  sku               = "Standard"

  # Azure requires a public IP for Internal-mode APIM's management plane
  # even though no API traffic ever reaches it — App Gateway remains the
  # platform's sole internet-facing ingress. See public_network_access note
  # below for the related, more surprising constraint.
  tags = var.tags
}

resource "azurerm_api_management" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  publisher_name  = var.publisher_name
  publisher_email = var.publisher_email
  sku_name        = var.sku_name
  zones           = var.zones

  # No public API traffic — clients reach APIM only through App Gateway in
  # snet-agw.
  virtual_network_type = "Internal"
  virtual_network_configuration {
    subnet_id = var.subnet_id
  }
  public_ip_address_id = azurerm_public_ip.this.id

  # NOT set to false here: the provider requires public_network_access_enabled
  # = true on creation even for Internal VNet mode (it only gates the
  # management plane, never the gateway/API traffic itself, which is already
  # confined to the VNet by virtual_network_type). Tightening this to false
  # is a legitimate follow-up change once the resource exists, not a day-one
  # setting — left at the provider default here rather than asserting
  # something that fails apply.

  identity {
    type         = "SystemAssigned"
  }

  dynamic "hostname_configuration" {
    for_each = var.custom_domain_name != null ? [1] : []
    content {
      proxy {
        host_name                        = var.custom_domain_name
        key_vault_certificate_id         = var.custom_domain_key_vault_secret_id
        ssl_keyvault_identity_client_id  = azurerm_user_assigned_identity.this.client_id
        default_ssl_binding              = true
      }
    }
  }

  protocols {
    http2_enabled = true
  }

  tags = var.tags
}
