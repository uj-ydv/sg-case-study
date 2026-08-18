variable "name" {
  description = "API Management service name."
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "publisher_name" {
  type = string
}

variable "publisher_email" {
  type = string
}

variable "sku_name" {
  description = "Only Developer and Premium support VNet integration. Developer_1 for dev/uat (no SLA); Premium_N for prod (SLA, zone redundancy)."
  type        = string
  default     = "Developer_1"
}

variable "zones" {
  description = "Availability zones — Premium tier only."
  type        = list(string)
  default     = null
}

variable "subnet_id" {
  description = "snet-apim — required for Internal VNet mode."
  type        = string
}

# --- TLS ---

variable "key_vault_id" {
  description = "Key Vault holding the custom-domain TLS certificate — the gateway's identity is granted Key Vault Secrets User here."
  type        = string
}

variable "custom_domain_name" {
  description = "Optional custom domain for the gateway (proxy) endpoint. Null uses the default <name>.azure-api.net hostname with a Microsoft-managed certificate — no Key Vault cert required."
  type        = string
  default     = null
}

variable "custom_domain_key_vault_secret_id" {
  description = "Versionless Key Vault secret ID of the PFX certificate for custom_domain_name. Required when custom_domain_name is set."
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
