# NOTE: built on azurerm_cognitive_account (kind = "AIServices") +
# azurerm_cognitive_account_project, the current Azure AI Foundry resource
# model. azurerm_ai_foundry / azurerm_ai_foundry_project are the older
# "classic hub" pattern and are documented as legacy — deliberately not used.

variable "name" {
  description = "Cognitive Services account name backing this AI Foundry instance."
  type        = string
}

variable "project_name" {
  description = "AI Foundry project name created under the account."
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "custom_subdomain_name" {
  description = "Globally unique subdomain. Required for Entra ID token auth and to attach a private endpoint at all — without it the account is unreachable under this platform's public-access-disabled model."
  type        = string
}

variable "sku_name" {
  type    = string
  default = "S0"
}

variable "agent_subnet_id" {
  description = "Optional dedicated subnet for AI Foundry Agent Service network injection (RFC1918 only). Leave null to skip agent networking."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet for the private endpoint (snet-pe-data)."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs for privatelink.cognitiveservices.azure.com, privatelink.openai.azure.com and privatelink.services.ai.azure.com."
  type        = list(string)
}

variable "key_vault_id" {
  type = string
}

variable "storage_account_id" {
  type = string
}

variable "container_registry_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
