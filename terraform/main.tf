provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

locals {
  prefix = "${var.app_name}-${var.env}"
  common_labels = {
    app = var.app_name
    env = var.env
    managed_by = "terraform"
  }
}

# ── Enable required GCP APIs ──────────────────────────────────
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "firebase.googleapis.com",
    "firebasehosting.googleapis.com",
    "fcm.googleapis.com",
    "servicenetworking.googleapis.com",
    "vpcaccess.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ])
  service            = each.value
  disable_on_destroy = false
}

# ── Networking ─────────────────────────────────────────────────
module "networking" {
  source     = "./modules/networking"
  project_id = var.project_id
  region     = var.region
  prefix     = local.prefix
  labels     = local.common_labels
  depends_on = [google_project_service.apis]
}


# ── Cloud SQL ──────────────────────────────────────────────────
module "cloudsql" {
  source      = "./modules/cloudsql"
  project_id  = var.project_id
  region      = var.region
  prefix      = local.prefix
  labels      = local.common_labels
  # DB password must be set manually to match the secret in Secret Manager
  network_id  = module.networking.vpc_id
  depends_on  = [module.networking]
}

# ── Cloud Storage ──────────────────────────────────────────────
module "storage" {
  source     = "./modules/storage"
  project_id = var.project_id
  region     = var.region
  prefix     = local.prefix
  labels     = local.common_labels
  depends_on = [google_project_service.apis]
}


# ── Secret Manager ─────────────────────────────────────────────
# All secrets must be created manually in Secret Manager. Pass their resource IDs below.

# ── CI/CD ──────────────────────────────────────────────────────
module "cicd" {
  source        = "./modules/cicd"
  project_id    = var.project_id
  region        = var.region
  prefix        = local.prefix
  labels        = local.common_labels
  github_owner  = var.github_owner
  github_repo   = var.github_repo
  depends_on    = [google_project_service.apis]
}

# ── Cloud Run ──────────────────────────────────────────────────
module "cloudrun" {
  source             = "./modules/cloudrun"
  project_id         = var.project_id
  region             = var.region
  prefix             = local.prefix
  labels             = local.common_labels
  image              = var.cloudrun_image
  min_instances      = var.cloudrun_min_instances
  max_instances      = var.cloudrun_max_instances
  vpc_connector_id   = module.networking.vpc_connector_id
  cloudsql_instance  = module.cloudsql.connection_name
  bucket_name        = module.storage.cards_bucket_name
  db_password_secret_id = var.db_password_secret_id
  apple_cert_base64_secret_id = var.apple_cert_base64_secret_id
  apple_cert_password_secret_id = var.apple_cert_password_secret_id
  google_wallet_service_account_key_secret_id = var.google_wallet_service_account_key_secret_id
  whatsapp_api_token_secret_id = var.whatsapp_api_token_secret_id
  sa_email           = module.cicd.cloudrun_sa_email
  depends_on         = [module.cloudsql, module.networking, module.cicd]
}

# ── Firebase ───────────────────────────────────────────────────
module "firebase" {
  source     = "./modules/firebase"
  project_id = var.project_id
  prefix     = local.prefix
  depends_on = [google_project_service.apis]
}

