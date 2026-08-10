resource "google_artifact_registry_repository" "lesson_backend_repo" {
  location      = var.region
  repository_id = "lesson-backend-repo"
  description   = "Docker images for the lesson backend service"
  format        = "DOCKER"
}
