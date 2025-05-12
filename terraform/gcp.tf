
provider "google" {
  credentials = file("terraform-sa-key.json")
  project     = "devops-mongo-storybooks"
  region      = "australia-southeast1"
  zone        = var.gcp_zone

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
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-http-${terraform.workspace}"]
}
# OS image
data "google_compute_image" "deb_image" {
  family  = "debian-12"
  project = "debian-cloud"
}
# Compute Engine Instance
resource "google_compute_instance" "instance" {
  name         = "${var.app_name}-vm-${terraform.workspace}"
  machine_type = var.gcp_machine_type
  zone         = var.gcp_zone
  tags         = ["allow-http-${terraform.workspace}"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.deb_image.self_link

    }
  }

  network_interface {
    network = data.google_compute_network.default.name

    access_config {
      nat_ip = google_compute_address.ip_address.address
    }
  }

  service_account {
    scopes = ["storage-ro"]
  }
}
