##############
# Cloudflare #
##############

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "cloudflare_api_token" {
  sensitive   = true
  type        = string
  description = "Account API token for Cloudflare"
}

variable "cloudflare_tunnel_id" {
  type        = string
  description = "Existing Cloudflare tunnel UUID. Get it from the Cloudflare dashboard."
}

variable "cloudflare_zone_id" {
  sensitive   = true
  type        = string
  description = "Cloudflare zone ID (root DNS zone) for homelab apps."
}

variable "cloudflare_domain" {
  description = "The root domain managed in Cloudflare for the homelab apps, without the https:// prefix (e.g., example.com)."
  type        = string
}

variable "cloudflare_admin_emails" {
  description = "List of admin emails for Cloudflare Zero Trust."
  type        = list(string)
}

variable "cloudflare_family_emails" {
  description = "List of family emails for Cloudflare Zero Trust."
  type        = list(string)
}

variable "r2_bucket_name" {
  type        = string
  description = "The name of the R2 bucket used for storing Terraform state files."
}

variable "r2_access_key_id" {
  type        = string
  description = "The access key ID for the R2 bucket."
}

variable "r2_secret_access_key" {
  type        = string
  description = "The secret access key for the R2 bucket."
}

variable "r2_endpoint" {
  type        = string
  description = "The endpoint for the R2 bucket used for storing Terraform state files."
}

variable "apps" {
  type = map(object({
    name        = string
    hostname    = string
    service     = string
    policy_type = string
  }))
  description = "Map of applications to expose through Cloudflare Tunnel. Each app requires a name, hostname (FQDN), backend service URL, and policy type (admin/family)."
}

#############
# Tailscale #
#############

variable "ts_api_key" {
  description = "API Key for Tailscale"
  type        = string
  sensitive   = true
}

variable "ts_org_name" {
  description = "Tailscale organization name"
  type        = string
}

variable "ts_tailnet" {
  description = "Tailscale tailnet name"
  type        = string
}
