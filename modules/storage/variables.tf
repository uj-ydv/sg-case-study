variable "name" {
  description = "Storage account name (globally unique, lowercase alphanumeric, 3-24 chars)."
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "account_replication_type" {
  type    = string
  default = "LRS"
}

variable "subresources" {
  description = "Storage subresources to provision private endpoints for (blob, file, table, queue, dfs)."
  type        = list(string)
  default     = ["blob"]
}

variable "subnet_id" {
  description = "Subnet for the private endpoint(s) (snet-pe-data)."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Map of subresource name to private DNS zone ID, e.g. { blob = <privatelink.blob.core.windows.net zone ID> }."
  type        = map(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
