output "hosting_url" {
  value = "https://${var.prefix}-dashboard.web.app"
}

output "hosting_site_id" {
  value = google_firebase_hosting_site.dashboard.site_id
}

