variable "project_id" {}
variable "region" {}
variable "prefix" {}
variable "labels" {}
variable "image" {}
variable "min_instances" {}
variable "max_instances" {}
variable "vpc_connector_id" {}
variable "cloudsql_instance" {}
variable "bucket_name" {}
variable "secret_ids" {}
variable "sa_email" {}

resource "google_cloud_run_v2_service" "api" {
  name     = "${var.prefix}-api"
  location = var.region
  project  = var.project_id
  labels   = var.labels

  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = var.sa_email
    timeout         = "30s"

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    vpc_access {
      connector = var.vpc_connector_id
      egress    = "PRIVATE_RANGES_ONLY"
    }

    containers {
      image = var.image

      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
        cpu_idle          = true  # only charge when processing requests
        startup_cpu_boost = true
      }

      # Cloud SQL connection
      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }

      # Static env vars
      env {
        name  = "NODE_ENV"
        value = "production"
      }
      env {
        name  = "GCS_BUCKET"
        value = var.bucket_name
      }
      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.project_id
      }

      # Secrets as env vars
      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = var.secret_ids["db_connection_string"]
            version = "latest"
          }
        }
      }
      env {
        name = "APPLE_CERT_BASE64"
        value_source {
          secret_key_ref {
            secret  = var.secret_ids["apple_cert_base64"]
            version = "latest"
          }
        }
      }
      env {
        name = "APPLE_CERT_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = var.secret_ids["apple_cert_password"]
            version = "latest"
          }
        }
      }
      env {
        name = "GOOGLE_WALLET_SA_KEY"
        value_source {
          secret_key_ref {
            secret  = var.secret_ids["google_wallet_service_account_key"]
            version = "latest"
          }
        }
      }
      env {
        name = "WHATSAPP_TOKEN"
        value_source {
          secret_key_ref {
            secret  = var.secret_ids["whatsapp_api_token"]
            version = "latest"
          }
        }
      }

      liveness_probe {
        http_get {
          path = "/health"
          port = 8080
        }
        initial_delay_seconds = 10
        period_seconds        = 30
        failure_threshold     = 3
      }

      startup_probe {
        http_get {
          path = "/health"
          port = 8080
        }
        initial_delay_seconds = 5
        period_seconds        = 5
        failure_threshold     = 10
      }
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [var.cloudsql_instance]
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

