variable "name" {
  description = "Application Gateway name."
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  description = "snet-agw — must be dedicated to Application Gateway resources only (Azure requirement)."
  type        = string
}

variable "min_capacity" {
  type    = number
  default = 2
}

variable "max_capacity" {
  type    = number
  default = 10
}

variable "waf_mode" {
  description = "Detection logs and allows; Prevention logs and blocks. Prevention is the enterprise-security default."
  type        = string
  default     = "Prevention"
}

# --- TLS ---

variable "key_vault_id" {
  description = "Key Vault holding the TLS certificate — the gateway's identity is granted Key Vault Secrets User here."
  type        = string
}

variable "ssl_certificate_key_vault_secret_id" {
  description = "Versionless Key Vault secret ID of the PFX certificate used for TLS termination."
  type        = string
}

# --- Backend (APIM) ---

variable "apim_gateway_hostname" {
  description = "APIM gateway hostname — used as the backend pool FQDN, the Host header sent to APIM, and the health probe host."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
