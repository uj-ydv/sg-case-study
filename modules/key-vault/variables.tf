variable "name" {
  description = "Key Vault name (globally unique, 3-24 chars)."
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID used for RBAC authorization."
  type        = string
}

variable "sku_name" {
  type    = string
  default = "standard"
}

variable "soft_delete_retention_days" {
  type    = number
  default = 90
}

variable "subnet_id" {
  description = "Subnet for the private endpoint (snet-pe-data)."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for privatelink.vaultcore.azure.net."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
