variable "project_id" {}
variable "prefix" {}
variable "labels" {}
variable "db_password" { sensitive = true }
variable "db_connection_string" { sensitive = true }
variable "apple_cert_base64" { sensitive = true; default = "placeholder" }
variable "apple_cert_password" { sensitive = true; default = "placeholder" }
variable "google_wallet_service_account_key" { sensitive = true; default = "placeholder" }
variable "whatsapp_api_token" { sensitive = true; default = "placeholder" }

locals {
  secrets = {
    db_password                       = var.db_password
    db_connection_string              = var.db_connection_string
    apple_cert_base64                 = var.apple_cert_base64
    apple_cert_password               = var.apple_cert_password
    google_wallet_service_account_key = var.google_wallet_service_account_key
    whatsapp_api_token                = var.whatsapp_api_token
  }
}

resource "google_secret_manager_secret" "secrets" {
  for_each  = local.secrets
  secret_id = "${var.prefix}-${each.key}"
  project   = var.project_id
  labels    = var.labels

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "versions" {
  for_each    = local.secrets
  secret      = google_secret_manager_secret.secrets[each.key].id
  secret_data = each.value
}

