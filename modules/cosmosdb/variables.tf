variable "name" {
  description = "Cosmos DB account name (globally unique)."
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "consistency_level" {
  type    = string
  default = "Session"
}

variable "subnet_id" {
  description = "Subnet for the private endpoint (snet-pe-data)."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for privatelink.documents.azure.com."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
