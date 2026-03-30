variable "project_id" {}
variable "prefix" {}
variable "labels" {}
variable "db_password" { sensitive = true }
variable "db_connection_string" { sensitive = true }
variable "apple_cert_base64" { sensitive = true; default = "placeholder" }
variable "apple_cert_password" { sensitive = true; default = "placeholder" }
variable "google_wallet_service_account_key" { sensitive = true; default = "placeholder" }
variable "whatsapp_api_token" { sensitive = true; default = "placeholder" }

