variable "project_id" {}
variable "region" {}
variable "prefix" {}
variable "labels" {}
variable "github_owner" {}
variable "github_repo" {}

resource "google_artifact_registry_repository" "repo" {
  repository_id = "${var.prefix}-repo"
  location      = var.region
  format        = "DOCKER"
  project       = var.project_id
  labels        = var.labels
  description   = "Docker images for ${var.prefix} services"
}

resource "google_service_account" "cloudrun_sa" {
  account_id   = "${var.prefix}-run-sa"
  display_name = "Cloud Run Runtime SA — ${var.prefix}"
  project      = var.project_id
}

resource "google_service_account" "cloudbuild_sa" {
  account_id   = "${var.prefix}-build-sa"
  display_name = "Cloud Build SA — ${var.prefix}"
  project      = var.project_id
}

resource "google_project_iam_member" "cloudrun_sa_roles" {
  for_each = toset([
    "roles/cloudsql.client",
    "roles/storage.objectAdmin",
    "roles/secretmanager.secretAccessor",
    "roles/firebase.sdkAdminServiceAgent",
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

resource "google_project_iam_member" "cloudbuild_sa_roles" {
  for_each = toset([
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
    "roles/artifactregistry.writer",
    "roles/cloudsql.client",
    "roles/storage.admin",
    "roles/secretmanager.secretAccessor",
    "roles/logging.logWriter",
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

resource "google_cloudbuild_trigger" "deploy" {
  count       = var.github_repo != "" ? 1 : 0
  name        = "${var.prefix}-deploy"
  project     = var.project_id
  description = "Build and deploy on push to main"
  service_account = google_service_account.cloudbuild_sa.id

  github {
    owner = var.github_owner
    name  = var.github_repo
    push {
      branch = "^main$"
    }
  }

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "build",
        "-t", "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}/api:$COMMIT_SHA",
        "-t", "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}/api:latest",
        "."
      ]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "push",
        "--all-tags",
        "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}/api"
      ]
    }
    step {
      name = "gcr.io/google.com/cloudsdktool/cloud-sdk"
      entrypoint = "gcloud"
      args = [
        "run", "deploy", "${var.prefix}-api",
        "--image", "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}/api:$COMMIT_SHA",
        "--region", var.region,
        "--platform", "managed",
        "--quiet"
      ]
    }
    options {
      logging = "CLOUD_LOGGING_ONLY"
    }
  }
}

