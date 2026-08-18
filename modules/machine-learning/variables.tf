variable "name" {
  description = "Machine Learning Workspace name."
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku_name" {
  type    = string
  default = "Standard"
}

variable "application_insights_id" {
  description = "Existing Application Insights resource ID. Assumed to come from the platform's enterprise monitoring capability rather than provisioned here."
  type        = string
}

variable "key_vault_id" {
  type = string
}

variable "storage_account_id" {
  description = "Backing storage account. Must not be Premium tier — azurerm_machine_learning_workspace doesn't support it."
  type        = string
}

variable "container_registry_id" {
  type = string
}

variable "subnet_id" {
  description = "Subnet for the private endpoint (snet-pe-data)."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs for privatelink.api.azureml.ms and privatelink.notebooks.azure.net."
  type        = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
