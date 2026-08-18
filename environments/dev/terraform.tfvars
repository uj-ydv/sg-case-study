environment  = "dev"
location     = "australiaeast"
project_name = "sgaip"

tags = {
  costcenter = "it"
  owner      = "platform-team"
}

storage_account_replication_type = "LRS"
apim_sku_name                    = "Developer_1"
# Dev runs the WAF in Detection so iteration isn't blocked by false
# positives; UAT and Prod run Prevention.
app_gateway_waf_mode = "Detection"

# The following are intentionally not set here — same reasoning as
# subscription_id/tenant_id — supply via TF_VAR_* or CI secrets/variables:
#   subnet_ids                                       (network team, per environment)
#   private_dns_zone_resource_group_name              (network team)
#   application_insights_id                           (existing enterprise monitoring)
#   app_gateway_ssl_certificate_key_vault_secret_id   (uploaded to Key Vault post-bootstrap)
#   subscription_id, tenant_id
