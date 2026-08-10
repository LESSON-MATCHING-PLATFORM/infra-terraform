data "google_secret_manager_secret_version" "db_password" {
  secret  = "DB_PASSWORD"
  version = "latest"
}

module "kafka_service" {
  source        = "./modules/kafka"
  username      = var.username
  instance_name = "kafka"
  machine_type  = "e2-medium"
  target_tags   = ["ssh", "kafka", "kafka-node", "node-exporter", "kafka-exporter"]
}

module "mysql_service" {
  source              = "./modules/mysql"
  username            = var.username
  instance_name       = "mysql"
  machine_type        = "e2-medium"
  target_tags         = ["ssh", "mysql", "mysql-node", "node-exporter", "mysqld-exporter"]
  mysql_root_password = data.google_secret_manager_secret_version.db_password.secret_data
}

module "elasticsearch" {
  source        = "./modules/elasticsearch"
  username      = var.username
  instance_name = "elasticsearch"
  machine_type  = "e2-medium"
  target_tags   = ["ssh", "elasticsearch"]
}

resource "null_resource" "update_all_secrets" {

  depends_on = [
    module.mysql_service,
    module.kafka_service
  ]

  triggers = {
    mysql_private = module.mysql_service.private_ip
    mysql_public  = module.mysql_service.public_ip

    kafka_private = module.kafka_service.private_ip
    kafka_public  = module.kafka_service.public_ip

  }

  provisioner "local-exec" {
    command = <<EOT

    printf "${module.mysql_service.public_ip}" | \
    gcloud secrets versions add DB_HOST --data-file=-
    echo "✅ DB VM IP 시크릿 버전 갱신 완료"

    printf "${module.kafka_service.public_ip}" | \
    gcloud secrets versions add KAFKA_BOOTSTRAP_SERVERS --data-file=-
    echo "✅ KAFKA VM IP 시크릿 버전 갱신 완료"

    EOT
  }

}
