output "cloudrun_url" {
  description = "Cloud Run service URL"
  value       = module.cloudrun.service_url
}

output "cloudsql_instance_name" {
  value = module.cloudsql.instance_name
}

output "cards_bucket_name" {
  value = module.storage.cards_bucket_name
}

output "artifact_registry_repo" {
  value = module.cicd.artifact_registry_url
}

output "firebase_hosting_url" {
  value = module.firebase.hosting_url
}

