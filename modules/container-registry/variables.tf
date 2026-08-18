variable "name" {
  description = "Container Registry name (globally unique, alphanumeric, 5-50 chars)."
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku" {
  description = "Premium is required for private endpoint support."
  type        = string
  default     = "Premium"
}

variable "subnet_id" {
  description = "Subnet for the private endpoint (snet-pe-data)."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for privatelink.azurecr.io."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
