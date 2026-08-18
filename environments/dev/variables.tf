variable "subscription_id" {
  description = "Azure subscription ID to deploy into."
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID."
  type        = string
}

variable "environment" {
  description = "Deployment environment name (dev, uat, prod)."
  type        = string
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "australiaeast"
}

variable "project_name" {
  description = "Short project/workload name used in resource naming."
  type        = string
  default     = "sgaip"
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

# --- Networking ---
# Owned by the platform/network team's hub-and-spoke Landing Zone — not
# provisioned by this repo. Not committed to tfvars, same reasoning as
# subscription_id/tenant_id: supply via TF_VAR_* or CI secrets/variables
# once the network team has provisioned the spoke for this environment.

variable "subnet_ids" {
  description = "Map of logical subnet name to subnet resource ID, provisioned by the platform/network team's hub-and-spoke spoke VNet for this environment. Raw pass-through — subnet names/IDs are project-specific and handed over directly, no data source lookup."
  type        = map(string)

  validation {
    condition = alltrue([
      for name in ["snet-agw", "snet-apim", "snet-appsvc", "snet-pe-data"] : contains(keys(var.subnet_ids), name)
    ])
    error_message = "subnet_ids must include snet-agw, snet-apim, snet-appsvc and snet-pe-data."
  }
}

variable "private_dns_zone_resource_group_name" {
  description = "Resource group in the hub/connectivity subscription holding the platform team's private DNS zones."
  type        = string
}

variable "private_dns_zone_names" {
  description = "Logical name -> well-known Azure private DNS zone name. Defaults cover every private endpoint / VNet-injected service this platform provisions."
  type        = map(string)
  default = {
    key_vault                    = "privatelink.vaultcore.azure.net"
    storage_blob                 = "privatelink.blob.core.windows.net"
    cosmosdb                     = "privatelink.documents.azure.com"
    container_registry           = "privatelink.azurecr.io"
    app_service                  = "privatelink.azurewebsites.net"
    ai_foundry_cognitiveservices = "privatelink.cognitiveservices.azure.com"
    ai_foundry_openai            = "privatelink.openai.azure.com"
    ai_foundry_services_ai       = "privatelink.services.ai.azure.com"
    machine_learning_api         = "privatelink.api.azureml.ms"
    machine_learning_notebooks   = "privatelink.notebooks.azure.net"
    # Internal-mode APIM has no azurerm_private_endpoint of its own; the
    # platform team must still link this zone to the spoke so App Gateway
    # (and anything else in the VNet) resolves the gateway hostname to
    # APIM's private IP instead of its public one.
    apim = "privatelink.azure-api.net"
  }
}

# --- Storage ---

variable "storage_account_replication_type" {
  type    = string
  default = "LRS"
}

# --- App Service ---

variable "app_service_plan_sku" {
  description = "Premium v3 tier or higher — required for both private endpoints and VNet integration on the same app."
  type        = string
  default     = "P1v3"
}

variable "app_container_image_name" {
  description = "Container image and tag the App Service pulls from ACR, e.g. internal-ai-app:latest."
  type        = string
  default     = "internal-ai-app:latest"
}

variable "app_container_port" {
  type    = number
  default = 8080
}

# --- Machine Learning ---

variable "application_insights_id" {
  description = "Existing Application Insights resource ID from the platform's enterprise monitoring capability. Not provisioned here — supply via TF_VAR_application_insights_id or CI secrets."
  type        = string
}

# --- APIM ---

variable "apim_publisher_name" {
  type    = string
  default = "Slater & Gordon"
}

variable "apim_publisher_email" {
  type    = string
  default = "platform-team@slatergordon.com.au"
}

variable "apim_sku_name" {
  description = "Only Developer and Premium support VNet integration. Developer_1 for dev/uat (no SLA); Premium_N for prod (SLA, zone redundancy)."
  type        = string
  default     = "Developer_1"
}

variable "apim_zones" {
  description = "Availability zones — Premium tier only."
  type        = list(string)
  default     = null
}

variable "apim_custom_domain_name" {
  description = "Optional custom domain for the APIM gateway endpoint. Null uses the default <name>.azure-api.net hostname with a Microsoft-managed certificate."
  type        = string
  default     = null
}

variable "apim_custom_domain_key_vault_secret_id" {
  type    = string
  default = null
}

# --- App Gateway ---

variable "app_gateway_min_capacity" {
  type    = number
  default = 2
}

variable "app_gateway_max_capacity" {
  type    = number
  default = 10
}

variable "app_gateway_waf_mode" {
  description = "Detection logs and allows; Prevention logs and blocks."
  type        = string
  default     = "Prevention"
}

variable "app_gateway_ssl_certificate_key_vault_secret_id" {
  description = "Versionless Key Vault secret ID for the gateway's TLS cert. Bootstrapping note: the certificate must be uploaded to Key Vault out-of-band (e.g. `az keyvault secret set`, or a separate pipeline) after module.key_vault exists and before this value is set — this repo does not automate certificate issuance/upload. Supply via TF_VAR_* or CI secrets."
  type        = string
}
