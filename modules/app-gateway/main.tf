resource "azurerm_public_ip" "this" {
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location

  allocation_method = "Static"
  sku               = "Standard"
  zones             = ["1", "2", "3"]

  tags = var.tags
}

locals {
  frontend_ip_name      = "feip-public"
  frontend_port_https   = "feport-443"
  frontend_port_http    = "feport-80"
  https_listener_name   = "listener-https"
  http_listener_name    = "listener-http"
  backend_pool_name     = "beap-apim"
  backend_settings_name = "be-htst-apim"
  probe_name            = "probe-apim"
  https_rule_name        = "rqrt-https"
  http_redirect_rule_name = "rqrt-http-redirect"
  redirect_config_name   = "rdrcfg-to-https"
  ssl_certificate_name   = "cert-primary"
}

resource "azurerm_application_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # This is the platform's single internet-facing frontend — everything it
  # forwards to (APIM, and beyond it App Service) is private/internal only.
  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.this.id

  identity {
    type         = "SystemAssigned"
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_name
    public_ip_address_id = azurerm_public_ip.this.id
  }

  frontend_port {
    name = local.frontend_port_https
    port = 443
  }

  frontend_port {
    name = local.frontend_port_http
    port = 80
  }

  # Retrieved from Key Vault via the user-assigned identity above. Key Vault
  # itself is private-endpoint-only, so this also depends on snet-agw having
  # network line-of-sight to the private endpoint in snet-pe-data — same
  # VNet, but worth calling out since it's a cross-subnet dependency that's
  # easy to miss when reasoning about this module in isolation.
  ssl_certificate {
    name                 = local.ssl_certificate_name
    key_vault_secret_id = var.ssl_certificate_key_vault_secret_id
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101S"
  }

  http_listener {
    name                           = local.https_listener_name
    frontend_ip_configuration_name = local.frontend_ip_name
    frontend_port_name             = local.frontend_port_https
    protocol                       = "Https"
    ssl_certificate_name           = local.ssl_certificate_name
  }

  # Plain HTTP exists only to redirect to HTTPS below — never forwarded to
  # the backend.
  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_name
    frontend_port_name             = local.frontend_port_http
    protocol                       = "Http"
  }

  # Backend is APIM's internal gateway hostname, not an IP — survives the
  # internal load balancer's IP changing. host_name below matches APIM's
  # bound hostname so its default/custom-domain certificate validates.
  backend_address_pool {
    name  = local.backend_pool_name
    fqdns = [var.apim_gateway_hostname]
  }

  # APIM exposes an unauthenticated health endpoint at this fixed path.
  probe {
    name                = local.probe_name
    protocol            = "Https"
    host                = var.apim_gateway_hostname
    path                = "/status-0123456789abcdef"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3

    match {
      status_code = ["200"]
    }
  }

  backend_http_settings {
    name                  = local.backend_settings_name
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    host_name             = var.apim_gateway_hostname
    request_timeout       = 30
    probe_name            = local.probe_name
  }

  request_routing_rule {
    name                        = local.https_rule_name
    rule_type                   = "Basic"
    priority                    = 100
    http_listener_name          = local.https_listener_name
    backend_address_pool_name   = local.backend_pool_name
    backend_http_settings_name  = local.backend_settings_name
  }

  redirect_configuration {
    name                  = local.redirect_config_name
    redirect_type         = "Permanent"
    target_listener_name  = local.https_listener_name
    include_path          = true
    include_query_string  = true
  }

  request_routing_rule {
    name                         = local.http_redirect_rule_name
    rule_type                    = "Basic"
    priority                     = 110
    http_listener_name           = local.http_listener_name
    redirect_configuration_name  = local.redirect_config_name
  }

  tags = var.tags
}
