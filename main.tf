module "mysql_service" {
  source        = "./modules/mysql"
  username      = var.username
  instance_name = "mysql"
  machine_type  = "e2-medium"
  target_tags   = ["ssh", "mysql-node", "node-exporter", "mysqld-exporter"]
}

module "elasticsearch_and_logstash" {
  source        = "./modules/elasticsearch"
  username      = var.username
  instance_name = "elasticsearch"
  machine_type  = "e2-medium"
  target_tags   = ["ssh", "elasticsearch", "logstash"]
}

module "kafka_service" {
  source        = "./modules/kafka"
  username      = var.username
  instance_name = "kafka"
  machine_type  = "e2-medium"
  target_tags   = ["ssh", "kafka-node", "node-exporter", "kafka-exporter"]
}

module "spring_service" {
  source        = "./modules/spring"
  username      = var.username
  instance_name = "spring"
  machine_type  = "e2-medium"
  target_tags   = ["ssh", "spring-node", "node-exporter"]
  logstash_ip   = module.elasticsearch_and_logstash.private_ip
  service_account_email = var.service_account_email

  depends_on = [
    module.mysql_service,
    module.elasticsearch_and_logstash
  ]
}

module "monitoring" {
  source            = "./modules/monitoring"
  username          = var.username
  instance_name     = "monitoring"
  machine_type      = "e2-medium"
  target_tags       = ["ssh", "prometheus", "grafana", "kibana"]
  spring_ip         = module.spring_service.private_ip
  mysql_ip          = module.mysql_service.private_ip
  kafka_ip          = module.kafka_service.private_ip
  elasticsearch_ip  = module.elasticsearch_and_logstash.private_ip

  depends_on = [
    module.spring_service,
    module.mysql_service,
    module.kafka_service,
    module.elasticsearch_and_logstash
  ]
}


# =========================================================================
# 인프라 완공 후 Secret Manager 통합 IP 업데이트 파이프라인
# =========================================================================


resource "null_resource" "update_all_secrets" {
  
  # 1. 의존성 격리: 모든 핵심 인프라 VM이 완전히 생성된 후 실행을 보장합니다.
  depends_on = [
    module.mysql_service,
    module.spring_service,
    module.kafka_service
  ]

  # 2. 변경 감지 트리거: 어떤 VM이든 IP가 하나라도 갱신되면 이 시크릿 주입 프로세스를 재가동합니다.
  triggers = {
    spring_private  = module.spring_service.private_ip
    spring_public   = module.spring_service.public_ip
    
    mysql_private   = module.mysql_service.private_ip
    mysql_public    = module.mysql_service.public_ip
    
    kafka_private   = module.kafka_service.private_ip
    kafka_public    = module.kafka_service.public_ip
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "========================================================================="
      echo " 🚀 [Secret Manager] 모든 인프라의 최신 IP 장부 업데이트를 시작합니다."
      echo "========================================================================="
      
      # -------------------------------------------------------------------------
      # 🌱 1. Spring Server IP 업데이트
      # -------------------------------------------------------------------------
      # printf "${module.spring_service.private_ip}" | \
      # gcloud secrets versions add spring-private-ip --data-file=-
      
      printf "${module.spring_service.public_ip}" | \
      gcloud secrets versions add SPRING_HOST --data-file=-
      echo "✅ Spring VM IP 시크릿 버전 갱신 완료"


      # -------------------------------------------------------------------------
      # 💾 2. Database Server IP 업데이트
      # -------------------------------------------------------------------------
      # printf "${module.mysql_service.private_ip}" | \
      # gcloud secrets versions add db-private-ip --data-file=-

      printf "${module.mysql_service.public_ip}" | \
      gcloud secrets versions add DB_HOST --data-file=-
      echo "✅ DB VM IP 시크릿 버전 갱신 완료"


      # -------------------------------------------------------------------------
      # 😾 3. Kafka Server IP 업데이트
      # -------------------------------------------------------------------------
      # printf "${module.kafka_service.private_ip}" | \
      # gcloud secrets versions add KAFKA_BOOTSTRAP_SERVERS --data-file=-
      
      printf "${module.kafka_service.public_ip}" | \
      gcloud secrets versions add KAFKA_BOOTSTRAP_SERVERS --data-file=-
      echo "✅ Kafka VM IP 시크릿 버전 갱신 완료"


      echo "========================================================================="
      echo " 🎉 [성공] 모든 서버의 인프라 형상 정보가 Secret Manager에 가동 등록되었습니다!"
      echo "========================================================================="
    EOT
  }
}

