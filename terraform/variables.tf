variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west1" # Belgium — closest to Morocco, good latency
}

variable "env" {
  description = "Environment: dev | staging | prod"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "env must be dev, staging, or prod."
  }
}

variable "app_name" {
  description = "Application name (used as prefix for resources)"
  type        = string
  default     = "fidelity"
}

variable "db_password" {
  description = "PostgreSQL admin password — set via TF_VAR_db_password env var"
  type        = string
  sensitive   = true
}

variable "apple_cert_base64" {
  description = "Apple Pass Type ID certificate (.p12) encoded in base64"
  type        = string
  sensitive   = true
  default     = ""
}

variable "apple_cert_password" {
  description = "Password for the Apple .p12 certificate"
  type        = string
  sensitive   = true
  default     = ""
}

variable "google_wallet_service_account_key" {
  description = "Google Wallet service account JSON key (base64)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "whatsapp_api_token" {
  description = "WhatsApp Business API token"
  type        = string
  sensitive   = true
  default     = ""
}

variable "github_owner" {
  description = "GitHub org or username for Cloud Build trigger"
  type        = string
  default     = ""
}

variable "github_repo" {
  description = "GitHub repository name for Cloud Build trigger"
  type        = string
  default     = ""
}

variable "cloudrun_image" {
  description = "Initial Cloud Run container image (updated by CI/CD)"
  type        = string
  default     = "gcr.io/cloudrun/hello" # placeholder for first deploy
}

variable "cloudrun_min_instances" {
  type    = number
  default = 0 # scale to zero in dev
}

variable "cloudrun_max_instances" {
  type    = number
  default = 10
}

