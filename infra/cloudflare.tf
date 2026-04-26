import {
  to = cloudflare_zero_trust_tunnel_cloudflared.docker_vm
  id = "${var.cloudflare_account_id}/${var.cloudflare_tunnel_id}"
}

locals {
  tunnel_cname             = "${var.cloudflare_tunnel_id}.cfargotunnel.com"
  cloudflare_admin_emails  = [for email in var.cloudflare_admin_emails : { email = { email = email } }]
  cloudflare_family_emails = [for email in var.cloudflare_family_emails : { email = { email = email } }]

  cloudflare_access_policy_admin = concat(
    local.cloudflare_admin_emails,
    [
      {
        geo = {
          country_code = "US"
        }
      }
    ]
  )

  cloudflare_access_policy_family = concat(
    local.cloudflare_family_emails,
    [
      {
        geo = {
          country_code = "US"
        }
      }
    ]
  )

  ingress_rules = concat(
    [for app in var.apps : {
      hostname = app.hostname
      service  = app.service
    }],
    [{
      service = "http_status:404"
    }]
  )

  policy_ids = {
    admin  = cloudflare_zero_trust_access_policy.admin.id
    family = cloudflare_zero_trust_access_policy.family.id
  }
}

data "cloudflare_zone" "homelab" {
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "docker_vm" {
  account_id = var.cloudflare_account_id
  name       = "thor"
  config_src = "cloudflare"
}

resource "cloudflare_dns_record" "apps" {
  for_each = var.apps

  zone_id = data.cloudflare_zone.homelab.zone_id
  name    = each.value.hostname
  ttl     = 1
  type    = "CNAME"
  comment = "Tunnel route for ${each.value.name}"
  content = local.tunnel_cname
  proxied = true
}

resource "cloudflare_dns_record" "caddy_proxy" {
  zone_id = data.cloudflare_zone.homelab.zone_id
  name    = "*.local.${var.cloudflare_domain}"
  content = "odin.${var.ts_tailnet}"
  ttl     = 1
  type    = "CNAME"
  comment = "Caddy reverse proxy for Tailscale"
  proxied = false
}

resource "cloudflare_zero_trust_access_application" "apps" {
  for_each = var.apps

  zone_id                   = var.cloudflare_zone_id
  name                      = each.value.name
  domain                    = each.value.hostname
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true

  policies = [
    { id = local.policy_ids[each.value.policy_type] },
  ]
}


resource "cloudflare_zero_trust_tunnel_cloudflared_config" "routes" {
  account_id = var.cloudflare_account_id
  tunnel_id  = var.cloudflare_tunnel_id
  config = {
    ingress = local.ingress_rules
  }
}

resource "cloudflare_zero_trust_access_policy" "admin" {
  account_id = var.cloudflare_account_id
  name       = "admin-users"
  decision   = "allow"
  include    = local.cloudflare_access_policy_admin
}

resource "cloudflare_zero_trust_access_policy" "family" {
  account_id = var.cloudflare_account_id
  name       = "family-users"
  decision   = "allow"
  include    = local.cloudflare_access_policy_family
}
