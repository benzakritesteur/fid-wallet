resource "google_firebase_project" "default" {
  provider = google-beta
  project  = var.project_id
}

resource "google_firebase_hosting_site" "dashboard" {
  provider = google-beta
  project  = var.project_id
  site_id  = "${var.prefix}-dashboard"
  depends_on = [google_firebase_project.default]
}
