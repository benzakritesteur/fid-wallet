output "instance_name" {
  value = google_sql_database_instance.postgres.name
}

output "connection_name" {
  value = google_sql_database_instance.postgres.connection_name
}

output "private_ip" {
  value = google_sql_database_instance.postgres.private_ip_address
}

output "connection_string" {
  sensitive = true
  value     = "postgresql://fidelity_app:${var.db_password}@${google_sql_database_instance.postgres.private_ip_address}/fidelity?sslmode=require"
}

