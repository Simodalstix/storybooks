variable "app_name" {
  type = string
}

variable "gcp_zone" {
  type        = string
  description = "GCP zone for resources (e.g. australia-southeast1-c)"
}


# Atlas
variable "mongodbatlas_public_key" {
  type = string
}
variable "mongodbatlas_private_key" {
  type = string
}

# Cloudflare

variable "cloudflare_api_token" {
  description = "API token for managing Cloudflare DNS"
  type        = string
}


# GCP

variable "gcp_machine_type" {
  type = string
}
