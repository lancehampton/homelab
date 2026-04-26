terraform {
  required_version = ">= 1.6.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.8.4"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.21.1"
    }
  }

  # https://developers.cloudflare.com/terraform/advanced-topics/remote-backend/
  backend "s3" {
    bucket                      = var.r2_bucket_name
    key                         = "proxmox/terraform.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    access_key                  = var.r2_access_key_id
    secret_key                  = var.r2_secret_access_key
    endpoints                   = { s3 = var.r2_endpoint }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "tailscale" {
  api_key = var.ts_api_key
  tailnet = var.ts_org_name
}
