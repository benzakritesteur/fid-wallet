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
  description = "Environment: dev | stage | prod"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "stage", "prod"], var.env)
    error_message = "env must be dev, stage, or prod."
  }
}

variable "app_name" {
  description = "Application name (used as prefix for resources)"
  type        = string
  default     = "fidelity"
}


# Secret Manager secret resource IDs (must be created manually)
variable "db_password_secret_id" {
  description = "Resource ID of the Secret Manager secret for the DB password (e.g. projects/xxx/secrets/xxx)"
  type        = string
}

variable "apple_cert_base64_secret_id" {
  description = "Resource ID of the Secret Manager secret for the Apple Pass Type ID certificate (.p12, base64)"
  type        = string
}

variable "apple_cert_password_secret_id" {
  description = "Resource ID of the Secret Manager secret for the Apple .p12 password"
  type        = string
}

variable "google_wallet_service_account_key_secret_id" {
  description = "Resource ID of the Secret Manager secret for the Google Wallet service account JSON key (base64)"
  type        = string
}

variable "whatsapp_api_token_secret_id" {
  description = "Resource ID of the Secret Manager secret for the WhatsApp Business API token"
  type        = string
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

