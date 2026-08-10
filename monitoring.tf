data "google_secret_manager_secret_version" "gf_security_admin_password" {
  secret  = "GF_SECURITY_ADMIN_PASSWORD"
  version = "latest"
}

module "monitoring" {
  source                     = "./modules/monitoring"
  username                   = var.username
  instance_name              = "monitoring"
  machine_type               = "e2-medium"
  target_tags                = ["ssh", "prometheus", "grafana", "kibana"]
  environment                = var.environment
  service_account_email      = google_service_account.vm_sa.email
  gf_security_admin_password = data.google_secret_manager_secret_version.gf_security_admin_password.secret_data
}

module "logstash" {
  source        = "./modules/logstash"
  username      = var.username
  instance_name = "logstash"
  machine_type  = "e2-medium"
  target_tags   = ["ssh", "logstash"]
  environment   = var.environment
}