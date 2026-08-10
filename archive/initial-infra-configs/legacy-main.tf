# Google Cloud 프로바이더 설정
provider "google" {
  project = "lessonplatform-495307"
  region  = "asia-northeast3"
}

# ==========================================================================
# Static IP 정의
# ==========================================================================

resource "google_compute_address" "kafka_ip" {
  name = "kafka-static-ip"
}

resource "google_compute_address" "monitoring_ip" {
  name = "monitoring-static-ip"
}

# ==========================================================================
# 방화벽 규칙 정의
# ==========================================================================

# kafka용 방화벽 규칙 (9092, 9094)
resource "google_compute_firewall" "kafka_firewall" {
  name    = "allow-kafka-and-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    # 22: SSH 접속용
    # 9092: Kafka 브로커 접속용
    ports    = ["22", "9092", "9094"]
  }

  source_ranges = ["0.0.0.0/0"]
  
  target_tags = ["kafka-node"]
}

# DB용 방화벽 규칙 (3306 포트 추가)
resource "google_compute_firewall" "db_firewall" {
  name    = "allow-mysql"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["db-node"]
}


# Spring 서버용 방화벽 규칙 (8080 포트 추가)
resource "google_compute_firewall" "spring_firewall" {
  name    = "allow-spring-app-and-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  
  target_tags = ["spring-node"]
}

# node exporter 방화벽 규칙 (9100 포트 추가)
resource "google_compute_firewall" "node_exporter_firewall" {
  name    = "allow-node-exporter-and-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    # 22: SSH 접속용
    # 9100: node exporter 접속용
    ports    = ["22", "9100"]
  }

  source_ranges = ["0.0.0.0/0"]
  
  target_tags = ["node-exporter"]
}

# mysqld exporter 방화벽 규칙 (9104 포트 추가)
resource "google_compute_firewall" "mysqld_exporter_firewall" {
  name    = "allow-mysqld-exporter-and-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    # 22: SSH 접속용
    # 9104: mysqld exporter 접속용
    ports    = ["22", "9104"]
  }

  source_ranges = ["0.0.0.0/0"]
  
  target_tags = ["mysqld-exporter"]
}

# kafka exporter 방화벽 규칙 (9308 포트 추가)
resource "google_compute_firewall" "kafka_exporter_firewall" {
  name    = "allow-kafka-exporter-and-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    # 22: SSH 접속용
    # 9308: kafka exporter 접속용
    ports    = ["22", "9308"]
  }

  source_ranges = ["0.0.0.0/0"]
  
  target_tags = ["kafka-exporter"]
}

# prometheus 방화벽 규칙 (9104 포트 추가)
resource "google_compute_firewall" "prometheus_firewall" {
  name    = "allow-prometheus-and-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    # 22: SSH 접속용
    # 9090: prometheus 접속용
    ports    = ["22", "9090"]
  }

  source_ranges = ["0.0.0.0/0"]
  
  target_tags = ["prometheus-node"]
}

# Grafana 방화벽 규칙 (3000 포트 추가)
resource "google_compute_firewall" "grafana_firewall" {
  name    = "allow-grafana-and-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    # 22: SSH 접속용
    # 3000: grafana 접속용
    ports    = ["22", "3000"]
  }

  source_ranges = ["0.0.0.0/0"]
  
  target_tags = ["grafana-node"]
}

# logstash 방화벽 규칙 (5044 포트 추가)
resource "google_compute_firewall" "logstash_firewall" {
  name    = "allow-logstash-and-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    # 22: SSH 접속용
    # 5044: logstash 접속용
    ports    = ["22", "5044"]
  }

  source_ranges = ["0.0.0.0/0"]
  
  target_tags = ["logstash-node"]
}

# elasticsearch 방화벽 규칙 (9200 포트 추가)
resource "google_compute_firewall" "elasticsearch_firewall" {
  name    = "allow-elasticsearch-and-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    # 22: SSH 접속용
    # 9200: elasticsearch 접속용
    ports    = ["22", "9200"]
  }

  source_ranges = ["0.0.0.0/0"]
  
  target_tags = ["elasticsearch-node"]
}

# kibana 방화벽 규칙 (5601 포트 추가)
resource "google_compute_firewall" "kibana_firewall" {
  name    = "allow-kibana-and-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    # 22: SSH 접속용
    # 5601: kibana 접속용
    ports    = ["22", "5601"]
  }

  source_ranges = ["0.0.0.0/0"]
  
  target_tags = ["kibana-node"]
}

# ==========================================================================
# VM 인스턴스 정의
# ==========================================================================

# kafka VM 인스턴스 정의
resource "google_compute_instance" "kafka_server" {
  name         = "kafka-instance"
  machine_type = "e2-medium"
  zone         = "asia-northeast3-a"

  tags = ["kafka-node", "node-exporter", "kafka-exporter"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts" # OS 선택
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.kafka_ip.address
    }
  }

  # 외부 파일을 불러와 스크립트로 전달
  metadata_startup_script = templatefile("${path.module}/scripts/setup.sh.tftpl", {
    username               = "hwan20202"
    app_name               = "kafka"
    docker_compose_content = templatefile("${path.module}/configs/docker-compose-kafka.yml.tftpl", {
      external_ip = google_compute_address.kafka_ip.address
    })
    init_sql_content       = "" # 필요 없음
    filebeat_yml_content   = "" # 필요 없음
  })
}

# MySQL VM 인스턴스 정의
resource "google_compute_instance" "db_server" {
  name         = "mysql-instance"
  machine_type = "e2-medium" # DB는 메모리 사용량이 있으니 최소 medium 권장
  zone         = "asia-northeast3-a"
  tags         = ["db-node", "node-exporter", "mysqld-exporter"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {
      # 외부 IP를 할당받기 위해 비워둠
    }
  }

  metadata_startup_script = templatefile("${path.module}/scripts/setup.sh.tftpl", {
    username               = "hwan20202"
    app_name               = "database"
    docker_compose_content = file("${path.module}/configs/docker-compose-db.yml")
    init_sql_content       = file("${path.module}/configs/mysql_init.sql")
    filebeat_yml_content   = "" # 필요 없음
  })
}

# Spring VM 인스턴스 정의
resource "google_compute_instance" "spring_server" {
  name         = "spring-app-vm"
  machine_type = "e2-medium"
  zone         = "asia-northeast3-a"

  tags = ["spring-node", "node-exporter"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {
      # 외부 IP를 할당받기 위해 비워둠
    }
  }

  metadata_startup_script = templatefile("${path.module}/scripts/setup.sh.tftpl", {
    username               = "hwan20202"
    app_name               = "spring-app"
    docker_compose_content = file("${path.module}/configs/docker-compose-spring.yml")
    init_sql_content       = "" # 필요 없음
    filebeat_yml_content   = templatefile("${path.module}/configs/filebeat.yml.tftpl", {
      logstash_ip = google_compute_address.monitoring_ip.address
    })
  })

  # Artifact Registry에서 이미지를 풀(Pull) 받을 수 있는 권한을 가진 서비스 계정 연결
  service_account {
    email  = "github-action@lessonplatform-495307.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  depends_on = [
    google_compute_instance.kafka_server,
    google_compute_instance.db_server
  ]
}

# Monitoring VM 인스턴스 정의
resource "google_compute_instance" "monitoring_server" {
  name         = "monitoring-instance"
  machine_type = "e2-medium"
  zone         = "asia-northeast3-a"

  tags = ["prometheus-node", "grafana-node", "logstash-node"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.monitoring_ip.address
    }
  }

  metadata_startup_script = templatefile("${path.module}/scripts/setup_monitoring.sh.tftpl", {
    username               = "hwan20202"
    app_name               = "monitoring"
    docker_compose_content = file("${path.module}/configs/docker-compose-monitoring.yml")
    prometheus_content     = templatefile("${path.module}/configs/prometheus.yml.tftpl", {
      spring_server_ip = google_compute_instance.spring_server.network_interface[0].network_ip
      kafka_server_ip  = google_compute_instance.kafka_server.network_interface[0].network_ip
      db_server_ip     = google_compute_instance.db_server.network_interface[0].network_ip
    })
    jvm_dashboard_content  = file("${path.module}/configs/grafana-dashboards/jvm-dashboard.json")
    mysql_dashboard_content  = file("${path.module}/configs/grafana-dashboards/mysql-exporter.json")
    kafka_dashboard_content  = file("${path.module}/configs/grafana-dashboards/kafka-exporter.json")
    logstash_conf_content = templatefile("${path.module}/configs/logstash.conf.tftpl", {
      elasticsearch_ip = google_compute_instance.elasticsearch_server.network_interface[0].network_ip
    })
  })

  depends_on = [
    google_compute_instance.kafka_server,
    google_compute_instance.db_server,
    google_compute_instance.spring_server,
    google_compute_instance.elasticsearch_server
  ]
}

# Elasticsearch VM 인스턴스 정의
resource "google_compute_instance" "elasticsearch_server" {
  name         = "eleasticsearch-instance"
  machine_type = "e2-medium"
  zone         = "asia-northeast3-a"
  tags = ["elasticsearch-node", "kibana-node"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {
      # 
    }
  }

  metadata_startup_script = templatefile("${path.module}/scripts/setup.sh.tftpl", {
    username               = "hwan20202"
    app_name               = "elasticsearch"
    docker_compose_content = file("${path.module}/configs/docker-compose-es.yml")
    init_sql_content       = "" # 필요 없음
    filebeat_yml_content   = "" # 필요 없음
  })
}

# =========================================================================
# 인프라 완공 후 Secret Manager 통합 IP 업데이트 파이프라인
# =========================================================================

resource "null_resource" "update_all_secrets" {
  
  # 1. 의존성 격리: 모든 핵심 인프라 VM이 완전히 생성된 후 실행을 보장합니다.
  depends_on = [
    google_compute_instance.spring_server,
    google_compute_instance.db_server,
    google_compute_instance.kafka_server
  ]

  # 2. 변경 감지 트리거: 어떤 VM이든 IP가 하나라도 갱신되면 이 시크릿 주입 프로세스를 재가동합니다.
  triggers = {
    spring_private  = google_compute_instance.spring_server.network_interface[0].network_ip
    spring_public   = google_compute_instance.spring_server.network_interface[0].access_config[0].nat_ip
    
    db_private      = google_compute_instance.db_server.network_interface[0].network_ip
    db_public      = google_compute_instance.db_server.network_interface[0].access_config[0].nat_ip
    
    kafka_private   = google_compute_instance.kafka_server.network_interface[0].network_ip
    kafka_public    = google_compute_instance.kafka_server.network_interface[0].access_config[0].nat_ip
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "========================================================================="
      echo " 🚀 [Secret Manager] 모든 인프라의 최신 IP 장부 업데이트를 시작합니다."
      echo "========================================================================="
      
      # -------------------------------------------------------------------------
      # 🌱 1. Spring Server IP 업데이트
      # -------------------------------------------------------------------------
      # printf "${google_compute_instance.spring_server.network_interface[0].network_ip}" | \
      # gcloud secrets versions add spring-private-ip --data-file=-
      
      printf "${google_compute_instance.spring_server.network_interface[0].access_config[0].nat_ip}" | \
      gcloud secrets versions add SPRING_HOST --data-file=-
      echo "✅ Spring VM IP 시크릿 버전 갱신 완료"


      # -------------------------------------------------------------------------
      # 💾 2. Database Server IP 업데이트
      # -------------------------------------------------------------------------
      # printf "${google_compute_instance.db_server.network_interface[0].network_ip}" | \
      # gcloud secrets versions add db-private-ip --data-file=-

      printf "${google_compute_instance.db_server.network_interface[0].access_config[0].nat_ip}" | \
      gcloud secrets versions add DB_HOST --data-file=-
      echo "✅ DB VM IP 시크릿 버전 갱신 완료"


      # -------------------------------------------------------------------------
      # 😾 3. Kafka Server IP 업데이트
      # -------------------------------------------------------------------------
      # printf "${google_compute_instance.kafka_server.network_interface[0].network_ip}" | \
      # gcloud secrets versions add KAFKA_BOOTSTRAP_SERVERS --data-file=-
      
      printf "${google_compute_instance.kafka_server.network_interface[0].access_config[0].nat_ip}" | \
      gcloud secrets versions add KAFKA_BOOTSTRAP_SERVERS --data-file=-
      echo "✅ Kafka VM IP 시크릿 버전 갱신 완료"


      echo "========================================================================="
      echo " 🎉 [성공] 모든 서버의 인프라 형상 정보가 Secret Manager에 가동 등록되었습니다!"
      echo "========================================================================="
    EOT
  }
}

