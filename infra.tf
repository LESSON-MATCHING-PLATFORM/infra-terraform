data "google_secret_manager_secret_version" "db_password" {
  secret  = "DB_PASSWORD"
  version = "latest"
}

locals {
  backend_database_name      = "fillinv_backend"
  notification_database_name = "fillinv_notification"
  ledger_database_name       = "fillinv_ledger"
  mysql_instance_zone        = "asia-northeast3-a"
  mysql_service_host         = "mysql.${local.mysql_instance_zone}.c.${var.project_id}.internal"
  kafka_service_host         = "kafka.${local.mysql_instance_zone}.c.${var.project_id}.internal"
  logstash_service_host      = "logstash.${local.mysql_instance_zone}.c.${var.project_id}.internal"
  backend_service_host       = "lesson-backend.${local.mysql_instance_zone}.c.${var.project_id}.internal"
  notification_service_host  = "notification-service.${local.mysql_instance_zone}.c.${var.project_id}.internal"
  ledger_service_host        = "lesson-ledger.${local.mysql_instance_zone}.c.${var.project_id}.internal"
}

module "kafka_service" {
  source        = "./modules/kafka"
  username      = var.username
  instance_name = "kafka"
  machine_type  = "e2-medium"
  target_tags   = ["ssh", "kafka", "kafka-node", "node-exporter", "kafka-exporter"]
  internal_host = local.kafka_service_host
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

resource "null_resource" "ensure_service_databases" {
  depends_on = [
    module.mysql_service
  ]

  triggers = {
    mysql_private         = module.mysql_service.private_ip
    backend_database      = local.backend_database_name
    notification_database = local.notification_database_name
    ledger_database       = local.ledger_database_name
  }

  provisioner "local-exec" {
    command = <<EOT

    gcloud compute ssh ${var.username}@mysql \
      --project ${var.project_id} \
      --zone ${local.mysql_instance_zone} \
      --tunnel-through-iap \
      --command "docker exec mysql-server sh -c 'mysql -uroot -p\"\$MYSQL_ROOT_PASSWORD\" -e \"CREATE DATABASE IF NOT EXISTS ${local.backend_database_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE DATABASE IF NOT EXISTS ${local.notification_database_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE DATABASE IF NOT EXISTS ${local.ledger_database_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; GRANT ALL PRIVILEGES ON ${local.ledger_database_name}.* TO \'root\'@\'%\'; FLUSH PRIVILEGES;\"'"
    echo "✅ Backend/Notification/Ledger DB 분리 생성 확인 완료"

    EOT
  }
}
