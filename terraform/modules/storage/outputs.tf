output "cards_bucket_name" {
  value = google_storage_bucket.cards.name
}

output "cards_bucket_url" {
  value = "gs://${google_storage_bucket.cards.name}"
}

output "assets_bucket_name" {
  value = google_storage_bucket.assets.name
}

