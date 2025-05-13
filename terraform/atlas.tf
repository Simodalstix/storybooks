# Configure the MongoDB Atlas Provider 
provider "mongodbatlas" {
  public_key  = var.mongodbatlas_public_key
  private_key = var.mongodbatlas_private_key
}
# Create the resources
resource "mongodbatlas_cluster" "mongo_cluster" {
  project_id   = var.atlas_project_id
  name         = "${var.app_name}-${terraform.workspace}"
  cluster_type = "REPLICASET"

  mongo_db_major_version = "8.0"

  provider_name               = "TENANT"
  provider_instance_size_name = "M0"
  backing_provider_name       = "GCP"
  provider_region_name        = "ASIA_SOUTHEAST_2" # or your preferred GCP-supported M0 region
}

# Cluster

# DB User
resource "mongodbatlas_database_user" "mongo_user" {
  username           = "storybooks-user-${terraform.workspace}"
  password           = var.atlas_user_password
  project_id         = var.atlas_project_id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "storybooks"
  }
}
# Whitelist IP
resource "mongodbatlas_project_ip_access_list" "acl" {
  project_id = var.atlas_project_id
  ip_address = google_compute_address.ip_address.address

}
