data "google_secret_manager_secret_version" "db_password" {
  secret  = "DB_PASSWORD"
  version = "latest"
}

locals {
  backend_database_name      = "fillinv_backend"
  notification_database_name = "fillinv_notification"
  mysql_instance_zone        = "asia-northeast3-a"
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

resource "null_resource" "ensure_service_databases" {
  depends_on = [
    module.mysql_service
  ]

  triggers = {
    mysql_private         = module.mysql_service.private_ip
    backend_database      = local.backend_database_name
    notification_database = local.notification_database_name
  }

  provisioner "local-exec" {
    command = <<EOT

    gcloud compute ssh ${var.username}@mysql \
      --project ${var.project_id} \
      --zone ${local.mysql_instance_zone} \
      --command "docker exec mysql-server sh -c 'mysql -uroot -p\"\$MYSQL_ROOT_PASSWORD\" -e \"CREATE DATABASE IF NOT EXISTS ${local.backend_database_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE DATABASE IF NOT EXISTS ${local.notification_database_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;\"'"
    echo "✅ Backend/Notification DB 분리 생성 확인 완료"

    EOT
  }
}

resource "null_resource" "update_backend_host_secret" {
  depends_on = [
    module.backend_service
  ]

  triggers = {
    backend_private = module.backend_service.private_ip
  }

  provisioner "local-exec" {
    command = <<EOT

    printf "${module.backend_service.private_ip}" | \
    gcloud secrets versions add BACKEND_HOST --data-file=-
    echo "✅ Backend VM IP 시크릿 버전 갱신 완료"

    EOT
  }
}

resource "null_resource" "update_notification_host_secret" {
  depends_on = [
    module.notification_service
  ]

  triggers = {
    notification_private = module.notification_service.private_ip
  }

  provisioner "local-exec" {
    command = <<EOT

    printf "${module.notification_service.private_ip}" | \
    gcloud secrets versions add NOTIFICATION_HOST --data-file=-
    echo "✅ Notification VM IP 시크릿 버전 갱신 완료"

    EOT
  }
}
