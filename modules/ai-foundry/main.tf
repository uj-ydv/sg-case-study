resource "azurerm_cognitive_account" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  kind     = "AIServices"
  sku_name = var.sku_name

  custom_subdomain_name       = var.custom_subdomain_name
  project_management_enabled = true

  identity {
    type = "SystemAssigned"
  }

  # AAD/RBAC only — no API keys issued for the data plane.
  local_auth_enabled = false

  public_network_access_enabled = false

  network_acls {
    default_action = "Deny"
    bypass          = "AzureServices"
  }

  # Agent Service network injection: only created when a dedicated subnet is
  # supplied. Most environments can skip this and rely on the private
  # endpoint below for inbound and RBAC for outbound.
  dynamic "network_injection" {
    for_each = var.agent_subnet_id != null ? [var.agent_subnet_id] : []
    content {
      scenario  = "agent"
      subnet_id = network_injection.value
    }
  }

  tags = var.tags
}

# Connectivity to Key Vault, Storage and Container Registry is RBAC-only
# (see rbac-assignments.tf), the same identity + role + private-endpoint
# pattern used by every other consumer in this platform — no embedded
# resource links on the account itself.
resource "azurerm_cognitive_account_project" "this" {
  name                 = var.project_name
  cognitive_account_id = azurerm_cognitive_account.this.id
  location             = var.location
  display_name         = var.project_name

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
