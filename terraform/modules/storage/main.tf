# Bucket for generated .pkpass files & merchant assets
resource "google_storage_bucket" "cards" {
  name                        = "${var.project_id}-${var.prefix}-cards"
  location                    = var.region
  project                     = var.project_id
  force_destroy               = true # set false in prod
  uniform_bucket_level_access = true
  labels                      = var.labels

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action { type = "Delete" }
    condition { age = 365 } # delete cards older than 1 year
  }

  cors {
    origin          = ["*"] # restrict to your domain in prod
    method          = ["GET", "HEAD"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }
}

# Bucket for merchant logo uploads (public read)
resource "google_storage_bucket" "assets" {
  name                        = "${var.project_id}-${var.prefix}-assets"
  location                    = var.region
  project                     = var.project_id
  force_destroy               = true
  uniform_bucket_level_access = true
  labels                      = var.labels
}

resource "google_storage_bucket_iam_member" "assets_public_read" {
  bucket = google_storage_bucket.assets.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
