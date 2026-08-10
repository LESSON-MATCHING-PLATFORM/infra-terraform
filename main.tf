# =========================================================================
# Provider 설정
# =========================================================================

provider "google" {
  project = var.project_id
  region  = var.region
}

# =========================================================================
# 기본 네트워크 설정
# =========================================================================

data "google_compute_network" "default" {
  name = "default"
}

# =========================================================================
# Cloud DNS 설정
# =========================================================================

# 내부 Private Managed Zone 생성
resource "google_dns_managed_zone" "private_zone" {
  name        = "lesson-platform-private-zone"
  dns_name    = "${var.environment}.internal."
  description = "마이크로서비스 내부 통신용 사설 DNS 존"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = data.google_compute_network.default.id
    }
  }
}

# 가상 도메인 레코드 (A Record) 생성 및 IP 바인딩

resource "google_dns_record_set" "es_log_record" {
  name         = "es-log.${google_dns_managed_zone.private_zone.dns_name}"
  managed_zone = google_dns_managed_zone.private_zone.name
  type         = "A"
  ttl          = 300 # DNS 캐시 유지 시간 (초)

  rrdatas = [module.elasticsearch.private_ip]
  depends_on = [
    module.elasticsearch
  ]
}


# =========================================================================
# 서비스 계정 및 권한
# =========================================================================

resource "google_service_account" "vm_sa" {
  account_id   = "hwan-vm-service-account"
  display_name = "백엔드 및 모니터링 VM 전용 서비스 계정"
}

locals {
  vm_roles = [
    "roles/dns.reader",
    "roles/compute.viewer",
    "roles/artifactregistry.reader",
    "roles/secretmanager.secretAccessor"
  ]
}

resource "google_project_iam_member" "vm_sa_roles" {
  for_each = toset(local.vm_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.vm_sa.email}"
}

# =========================================================================
# 인프라 완공 후 Secret Manager 통합 IP 업데이트 파이프라인
# =========================================================================

/*
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
*/
