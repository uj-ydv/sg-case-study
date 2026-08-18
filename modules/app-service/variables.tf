variable "name" {
  description = "App Service name (globally unique — forms the default *.azurewebsites.net hostname)."
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "service_plan_sku" {
  description = "Premium v3 tier or higher — required for both private endpoints and VNet integration on the same app."
  type        = string
  default     = "P1v3"
}

# --- Connectivity ---

variable "vnet_integration_subnet_id" {
  description = "snet-appsvc — regional VNet integration subnet used for outbound calls to Key Vault, Storage, Cosmos DB, ACR."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "snet-pe-data — subnet for the inbound private endpoint (APIM/App Gateway reach the app through this, not the public hostname)."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for privatelink.azurewebsites.net."
  type        = string
}

# --- Container image ---

variable "container_registry_login_server" {
  description = "ACR login server the app pulls its image from, e.g. sgacrdev.azurecr.io."
  type        = string
}

variable "container_image_name" {
  description = "Image name and tag, e.g. internal-ai-app:latest."
  type        = string
}

variable "container_port" {
  description = "Port the container listens on, exposed via WEBSITES_PORT."
  type        = number
  default     = 8080
}

# --- Backend resource IDs for RBAC + app settings ---

variable "key_vault_id" {
  type = string
}

variable "key_vault_uri" {
  type = string
}

variable "storage_account_id" {
  type = string
}

variable "storage_blob_endpoint" {
  type = string
}

variable "cosmosdb_account_id" {
  type = string
}

variable "cosmosdb_account_name" {
  type = string
}

variable "cosmosdb_endpoint" {
  type = string
}

variable "container_registry_id" {
  type = string
}

variable "app_settings" {
  description = "Additional, non-secret app settings to merge in. Secrets are fetched at runtime via managed identity — never stored here."
  type        = map(string)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
