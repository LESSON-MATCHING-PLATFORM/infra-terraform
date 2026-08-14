module "api_gateway_service" {
  source                = "./modules/gateway"
  username              = var.username
  instance_name         = "api-gateway"
  machine_type          = "e2-medium"
  target_tags           = ["gateway", "ssh", "spring", "spring-node", "node-exporter"]
  logstash_ip           = module.logstash.private_ip
  environment           = var.environment
  service_account_email = google_service_account.vm_sa.email

  depends_on = [
    module.logstash
  ]
}

module "backend_service" {
  source                = "./modules/spring"
  username              = var.username
  instance_name         = "lesson-backend"
  machine_type          = "e2-medium"
  target_tags           = ["ssh", "spring", "spring-node", "node-exporter"]
  static_ip_name        = "lesson-backend-static-ip"
  logstash_ip           = module.logstash.private_ip
  environment           = var.environment
  service_account_email = google_service_account.vm_sa.email
  spring_server_image   = "asia-northeast3-docker.pkg.dev/${var.project_id}/backend-server-repo/spring-app:latest"
  spring_environment    = "      SPRING_PROFILES_ACTIVE: gcp"

  depends_on = [
    module.mysql_service,
    module.kafka_service,
    module.logstash
  ]
}

module "notification_service" {
  source                = "./modules/spring"
  username              = var.username
  instance_name         = "notification-service"
  machine_type          = "e2-medium"
  target_tags           = ["ssh", "spring", "spring-node", "node-exporter"]
  static_ip_name        = "spring-static-ip"
  logstash_ip           = module.logstash.private_ip
  environment           = var.environment
  service_account_email = google_service_account.vm_sa.email
  spring_server_image   = "asia-northeast3-docker.pkg.dev/lessonplatform-495307/notification-server-repo/spring-app:latest"
  spring_environment    = <<-EOT
      - FIREBASE_PROJECT_ID=${var.project_id}
      - GOOGLE_CLOUD_PROJECT=${var.project_id}
  EOT

  depends_on = [
    module.mysql_service,
    module.logstash
  ]
}
