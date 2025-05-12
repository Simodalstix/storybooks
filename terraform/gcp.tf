
provider "google" {
  credentials = file("terraform-sa-key.json")
  project     = "devops-mongo-storybooks"
  region      = "australia-southeast1"
  zone        = "australia-southeast1"
}

# IP address
resource "google_compute_address" "ip_address" {
  name = "storybooks-ip-${terraform.workspace}"
}
# Network
data "google_compute_network" "default" {
  name = "default"
}
# Firewall wall
resource "google_compute_firewall" "default" {
  name    = "allow-http-${terraform.workspace}"
  network = data.google_compute_network.default

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-http-${terraform.workspace}"]
}
# OS image
data "google_compute_image" "debian" {
  family  = "debian-12"
  project = "debian-cloud"
}
# Compute Engine Instance
