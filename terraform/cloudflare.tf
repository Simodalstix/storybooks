provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "cloudflare_zone" "existing" {
  zone_id = var.cloudflare_zone_id
}
resource "cloudflare_dns_record" "example_dns_record" {
  zone_id = var.cloudflare_zone_id
  name    = "storybooks${terraform.workspace == "prod" ? "" : "-${terraform.workspace}"}"
  type    = "A"
  content = google_compute_address.ip_address.address
  proxied = true
  ttl     = 1
}
