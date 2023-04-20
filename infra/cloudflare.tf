terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

resource "cloudflare_record" "alert" {
  name    = "alert"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "140.238.198.209"
  zone_id = var.zone
}

