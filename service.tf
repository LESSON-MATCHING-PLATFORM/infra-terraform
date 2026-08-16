module "api_gateway_service" {
  source                = "./modules/gateway"
  username              = var.username
  instance_name         = "api-gateway"
  machine_type          = "e2-medium"
  target_tags           = ["gateway", "ssh", "spring", "spring-node", "node-exporter"]
  logstash_ip           = local.logstash_service_host
  environment           = var.environment
  service_account_email = google_service_account.vm_sa.email
  backend_host          = local.backend_service_host
  notification_host     = local.notification_service_host
  ledger_host           = local.ledger_service_host

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
  logstash_ip           = local.logstash_service_host
  environment           = var.environment
  service_account_email = google_service_account.vm_sa.email
  spring_server_image   = "asia-northeast3-docker.pkg.dev/${var.project_id}/backend-server-repo/spring-app:latest"
  spring_environment = {
    SPRING_PROFILES_ACTIVE  = "gcp"
    DB_HOST                 = local.mysql_service_host
    KAFKA_BOOTSTRAP_SERVERS = local.kafka_service_host
    LEDGER_HOST             = local.ledger_service_host
  }

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
  logstash_ip           = local.logstash_service_host
  environment           = var.environment
  service_account_email = google_service_account.vm_sa.email
  spring_server_image   = "asia-northeast3-docker.pkg.dev/lessonplatform-495307/notification-server-repo/spring-app:latest"
  spring_environment = {
    FIREBASE_PROJECT_ID     = var.project_id
    GOOGLE_CLOUD_PROJECT    = var.project_id
    FIREBASE_DRY_RUN        = tostring(var.firebase_dry_run)
    DB_HOST                 = local.mysql_service_host
    KAFKA_BOOTSTRAP_SERVERS = local.kafka_service_host
  }

  depends_on = [
    module.mysql_service,
    module.logstash
  ]
}

module "ledger_service" {
  source                = "./modules/spring"
  username              = var.username
  instance_name         = "lesson-ledger"
  machine_type          = "e2-medium"
  target_tags           = ["ssh", "spring", "spring-node", "node-exporter"]
  logstash_ip           = local.logstash_service_host
  environment           = var.environment
  service_account_email = google_service_account.vm_sa.email
  spring_server_image   = "asia-northeast3-docker.pkg.dev/${var.project_id}/ledger-server-repo/spring-app:latest"
  spring_environment = {
    SPRING_PROFILES_ACTIVE = "gcp"
    DB_HOST                = local.mysql_service_host
  }

  depends_on = [
    module.mysql_service,
    module.logstash
  ]
}
