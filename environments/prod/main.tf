locals {
  resource_prefix = "${var.project_name}-${var.environment}"
  # Azure resource-name character rules differ per type; this variant strips
  # separators for resources that don't allow hyphens (storage, ACR).
  name_no_dash = replace(local.resource_prefix, "-", "")

  common_tags = merge(
    var.tags,
    {
      environment = var.environment
      project     = var.project_name
      managed_by  = "terraform"
    }
  )
}

# Shared suffix for globally-unique Azure resource names (Key Vault, Storage,
# ACR, Cosmos DB, App Service, AI Foundry, APIM all compete for names against
# every other Azure tenant, not just this subscription).
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.resource_prefix}"
  location = var.location

  tags = local.common_tags
}

# DNS zone names are fixed Azure constants, so a lookup by name is cheap
# validation that the platform team has actually linked them — a typo or
# missing zone fails plan here instead of surfacing as a mysterious DNS
# resolution failure deep inside some other module's private endpoint.
data "azurerm_private_dns_zone" "this" {
  for_each = var.private_dns_zone_names

  name                = each.value
  resource_group_name = var.private_dns_zone_resource_group_name
}

module "key_vault" {
  source = "../../modules/key-vault"

  name                = "${local.resource_prefix}-kv-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  tenant_id           = var.tenant_id

  subnet_id           = var.subnet_ids["snet-pe-data"]
  private_dns_zone_id = data.azurerm_private_dns_zone.this["key_vault"].id

  tags = local.common_tags
}

module "storage" {
  source = "../../modules/storage"

  name                     = "${lower(local.name_no_dash)}st${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  account_replication_type = var.storage_account_replication_type

  subnet_id            = var.subnet_ids["snet-pe-data"]
  private_dns_zone_ids = { blob = data.azurerm_private_dns_zone.this["storage_blob"].id }

  tags = local.common_tags
}

module "cosmosdb" {
  source = "../../modules/cosmosdb"

  name                = lower("${local.resource_prefix}-cosmos-${random_string.suffix.result}")
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location

  subnet_id           = var.subnet_ids["snet-pe-data"]
  private_dns_zone_id = data.azurerm_private_dns_zone.this["cosmosdb"].id

  tags = local.common_tags
}

module "container_registry" {
  source = "../../modules/container-registry"

  name                = "${lower(local.name_no_dash)}acr${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location

  subnet_id           = var.subnet_ids["snet-pe-data"]
  private_dns_zone_id = data.azurerm_private_dns_zone.this["container_registry"].id

  tags = local.common_tags
}

module "app_service" {
  source = "../../modules/app-service"

  name                = "${local.resource_prefix}-app-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  service_plan_sku    = var.app_service_plan_sku

  vnet_integration_subnet_id = var.subnet_ids["snet-appsvc"]
  private_endpoint_subnet_id = var.subnet_ids["snet-pe-data"]
  private_dns_zone_id        = data.azurerm_private_dns_zone.this["app_service"].id

  container_registry_login_server = module.container_registry.login_server
  container_image_name            = var.app_container_image_name
  container_port                  = var.app_container_port

  key_vault_id          = module.key_vault.id
  key_vault_uri         = module.key_vault.uri
  storage_account_id    = module.storage.id
  storage_blob_endpoint = module.storage.primary_blob_endpoint
  cosmosdb_account_id   = module.cosmosdb.id
  cosmosdb_account_name = module.cosmosdb.name
  cosmosdb_endpoint     = module.cosmosdb.endpoint
  container_registry_id = module.container_registry.id

  tags = local.common_tags
}

module "ai_foundry" {
  source = "../../modules/ai-foundry"

  name                  = "${local.resource_prefix}-aif-${random_string.suffix.result}"
  project_name          = "${local.resource_prefix}-aif-project"
  resource_group_name   = azurerm_resource_group.this.name
  location              = var.location
  custom_subdomain_name = "${local.resource_prefix}-aif-${random_string.suffix.result}"

  subnet_id = var.subnet_ids["snet-pe-data"]
  private_dns_zone_ids = [
    data.azurerm_private_dns_zone.this["ai_foundry_cognitiveservices"].id,
    data.azurerm_private_dns_zone.this["ai_foundry_openai"].id,
    data.azurerm_private_dns_zone.this["ai_foundry_services_ai"].id,
  ]

  key_vault_id          = module.key_vault.id
  storage_account_id    = module.storage.id
  container_registry_id = module.container_registry.id

  tags = local.common_tags
}

module "machine_learning" {
  source = "../../modules/machine-learning"

  name                    = "${local.resource_prefix}-mlw"
  resource_group_name     = azurerm_resource_group.this.name
  location                = var.location
  application_insights_id = var.application_insights_id

  key_vault_id          = module.key_vault.id
  storage_account_id    = module.storage.id
  container_registry_id = module.container_registry.id

  subnet_id = var.subnet_ids["snet-pe-data"]
  private_dns_zone_ids = [
    data.azurerm_private_dns_zone.this["machine_learning_api"].id,
    data.azurerm_private_dns_zone.this["machine_learning_notebooks"].id,
  ]

  tags = local.common_tags
}

# Bootstrapping order: apply once to create module.key_vault, upload the
# APIM/App Gateway TLS certificate(s) into it out-of-band, then set
# apim_custom_domain_key_vault_secret_id / app_gateway_ssl_certificate_key_vault_secret_id
# and apply again. Neither certificate is issued or uploaded by this repo.
module "apim" {
  source = "../../modules/apim"

  name                = "${local.resource_prefix}-apim-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location

  publisher_name  = var.apim_publisher_name
  publisher_email = var.apim_publisher_email
  sku_name        = var.apim_sku_name
  zones           = var.apim_zones

  subnet_id = var.subnet_ids["snet-apim"]

  key_vault_id                      = module.key_vault.id
  custom_domain_name                = var.apim_custom_domain_name
  custom_domain_key_vault_secret_id = var.apim_custom_domain_key_vault_secret_id

  tags = local.common_tags
}

module "app_gateway" {
  source = "../../modules/app-gateway"

  name                = "${local.resource_prefix}-agw"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location

  subnet_id    = var.subnet_ids["snet-agw"]
  min_capacity = var.app_gateway_min_capacity
  max_capacity = var.app_gateway_max_capacity
  waf_mode     = var.app_gateway_waf_mode

  key_vault_id                        = module.key_vault.id
  ssl_certificate_key_vault_secret_id = var.app_gateway_ssl_certificate_key_vault_secret_id
  apim_gateway_hostname               = module.apim.gateway_hostname

  tags = local.common_tags
}
