resource "random_id" "db_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "postgres" {
  name             = "${var.prefix}-pg-${random_id.db_suffix.hex}"
  database_version = "POSTGRES_15"
  region           = var.region
  project          = var.project_id

  deletion_protection = false # set true in prod

  settings {
    tier              = "db-f1-micro" # upgrade to db-g1-small for stage/prod
    availability_type = "ZONAL"       # use REGIONAL for prod HA
    disk_autoresize   = true
    disk_size         = 10
    disk_type         = "PD_SSD"

    user_labels = var.labels

    ip_configuration {
      ipv4_enabled    = false # private IP only
      private_network = var.network_id
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = true
      backup_retention_settings {
        retained_backups = 7
      }
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = false
    }

    maintenance_window {
      day          = 7  # Sunday
      hour         = 4
      update_track = "stable"
    }
  }
}

resource "google_sql_database" "fidelity_db" {
  name     = "fidelity"
  instance = google_sql_database_instance.postgres.name
  project  = var.project_id
}


# NOTE: The DB user must be created manually with the password stored in Secret Manager.
