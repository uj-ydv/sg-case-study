environment  = "prod"
location     = "australiaeast"
project_name = "sgaip"

tags = {
  costcenter = "it"
  owner      = "platform-team"
}

# Geo-redundant storage, Premium/zone-redundant APIM (SLA-backed), and
# Prevention-mode WAF — the only environment that pays for all three.
storage_account_replication_type = "GRS"
apim_sku_name                    = "Premium_1"
apim_zones                       = ["1", "2", "3"]
app_gateway_waf_mode             = "Prevention"

# The following are intentionally not set here — same reasoning as
# subscription_id/tenant_id — supply via TF_VAR_* or CI secrets/variables:
#   subnet_ids                                       (network team, per environment)
#   private_dns_zone_resource_group_name              (network team)
#   application_insights_id                           (existing enterprise monitoring)
#   app_gateway_ssl_certificate_key_vault_secret_id   (uploaded to Key Vault post-bootstrap)
#   subscription_id, tenant_id
