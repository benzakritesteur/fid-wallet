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
  db_password = var.db_password
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
module "secrets" {
  source                            = "./modules/secrets"
  project_id                        = var.project_id
  prefix                            = local.prefix
  labels                            = local.common_labels
  db_password                       = var.db_password
  db_connection_string              = module.cloudsql.connection_string
  apple_cert_base64                 = var.apple_cert_base64
  apple_cert_password               = var.apple_cert_password
  google_wallet_service_account_key = var.google_wallet_service_account_key
  whatsapp_api_token                = var.whatsapp_api_token
  depends_on                        = [google_project_service.apis]
}

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
  secret_ids         = module.secrets.secret_ids
  sa_email           = module.cicd.cloudrun_sa_email
  depends_on         = [module.cloudsql, module.secrets, module.networking, module.cicd]
}

# ── Firebase ───────────────────────────────────────────────────
module "firebase" {
  source     = "./modules/firebase"
  project_id = var.project_id
  prefix     = local.prefix
  depends_on = [google_project_service.apis]
}

