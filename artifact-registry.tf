import {
  to = google_artifact_registry_repository.backend_server_repo
  id = "projects/${var.project_id}/locations/${var.region}/repositories/backend-server-repo"
}

resource "google_artifact_registry_repository" "backend_server_repo" {
  location      = var.region
  repository_id = "backend-server-repo"
  description   = "Docker images for the lesson backend service"
  format        = "DOCKER"
}
