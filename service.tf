module "api_gateway_service" {
  source                = "./modules/gateway"
  username              = var.username
  instance_name         = "api-gateway"
  machine_type          = "e2-medium"
  target_tags           = ["gateway", "ssh", "spring", "spring-node", "node-exporter"]
  logstash_ip           = module.logstash.private_ip
  service_account_email = google_service_account.vm_sa.email

  depends_on = [
    module.logstash
  ]
}

module "notification_service" {
  source                = "./modules/spring"
  username              = var.username
  instance_name         = "notification-service"
  machine_type          = "e2-medium"
  target_tags           = ["ssh", "spring", "spring-node", "node-exporter"]
  logstash_ip           = module.logstash.private_ip
  service_account_email = google_service_account.vm_sa.email
  spring_server_image   = "asia-northeast3-docker.pkg.dev/lessonplatform-495307/notification-server-repo/spring-app:latest"

  depends_on = [
    module.mysql_service,
    module.logstash
  ]
}
