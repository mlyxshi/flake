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
}

resource "cloudflare_record" "au" {
  name    = "au"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "140.238.198.209"
}

resource "cloudflare_record" "cache" {
  name    = "cache"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "155.248.196.71"
}


resource "cloudflare_record" "changeio" {
  name    = "changeio"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "152.67.79.165"
}

resource "cloudflare_record" "de" {
  name    = "de"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "130.61.171.180"
}

resource "cloudflare_record" "flexget" {
  name    = "flexget"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "130.61.171.180"
}


resource "cloudflare_record" "hk1" {
  name    = "hk1"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "20.187.108.216"
}

resource "cloudflare_record" "hk2" {
  name    = "hk2"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "20.24.211.59"
}

resource "cloudflare_record" "hydra" {
  name    = "hydra"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "152.69.224.200"
}

resource "cloudflare_record" "hydra-x64" {
  name    = "hydra-x64"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "152.67.211.22"
}

resource "cloudflare_record" "jellyfin" {
  name    = "jellyfin"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "168.138.34.176"
}

resource "cloudflare_record" "jp1" {
  name    = "jp1"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "138.3.223.82"
}

resource "cloudflare_record" "jp2" {
  name    = "jp2"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "138.2.16.45"
}

resource "cloudflare_record" "jp3" {
  name    = "jp3"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "20.78.245.202"
}

resource "cloudflare_record" "jp4" {
  name    = "jp4"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "168.138.34.176"
}

resource "cloudflare_record" "kr2" {
  name    = "kr2"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "152.67.211.22"
}

resource "cloudflare_record" "kr" {
  name    = "kr"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "152.69.224.200"
}

resource "cloudflare_record" "metric" {
  name    = "metric"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "140.238.198.209"
}

resource "cloudflare_record" "miniflux" {
  name    = "miniflux"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "138.2.224.150"
}

resource "cloudflare_record" "miniflux-silent" {
  name    = "miniflux-silent"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "138.2.224.150"
}

resource "cloudflare_record" "minio-dashboard" {
  name    = "minio-dashboard"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "155.248.196.71"
}

resource "cloudflare_record" "minio" {
  name    = "minio"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "155.248.196.71"
}

resource "cloudflare_record" "password" {
  name    = "password"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "152.67.78.74"
}

resource "cloudflare_record" "reddit" {
  name    = "reddit"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "155.248.196.71"
}

resource "cloudflare_record" "rss" {
  name    = "rss"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "152.67.79.165"
}

resource "cloudflare_record" "sw2" {
  name    = "sw2"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "152.67.76.109"
}

resource "cloudflare_record" "sw3" {
  name    = "sw3"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "152.67.78.74"
}

resource "cloudflare_record" "sw" {
  name    = "sw"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "152.67.79.165"
}

resource "cloudflare_record" "top" {
  name    = "top"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "152.67.76.109"
}

resource "cloudflare_record" "transmission-index" {
  name    = "transmission-index"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "130.61.171.180"
}

resource "cloudflare_record" "transmission" {
  name    = "transmission"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "130.61.171.180"
}

resource "cloudflare_record" "us1" {
  name    = "us1"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "155.248.196.71"
}

resource "cloudflare_record" "us2" {
  name    = "us2"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "138.2.224.150"
}

resource "cloudflare_record" "youtube" {
  name    = "youtube"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "155.248.196.71"
}
