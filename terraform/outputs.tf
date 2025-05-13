output "cluster_name" {
  value       = mongodbatlas_cluster.mongo_cluster.name
  description = "The name of the MongoDB Atlas cluster"
}

output "connection_string" {
  value       = mongodbatlas_cluster.mongo_cluster.connection_strings[0].standard_srv
  sensitive   = true
  description = "The SRV connection string (hide in sensitive output)"
}
