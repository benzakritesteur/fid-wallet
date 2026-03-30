output "cloudrun_sa_email" {
  value = google_service_account.cloudrun_sa.email
}

output "cloudbuild_sa_email" {
  value = google_service_account.cloudbuild_sa.email
}

output "artifact_registry_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}"
}

