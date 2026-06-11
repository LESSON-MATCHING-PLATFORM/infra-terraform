# Monitoring 고유 static IP
resource "google_compute_address" "monitoring_ip" {
  name = "monitoring-static-ip"
}

# Monitoring VM 인스턴스 정의
resource "google_compute_instance" "monitoring_server" {
  name          = var.instance_name
  machine_type  = var.machine_type
  zone          = var.zone
  tags          = var.target_tags

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

  metadata_startup_script = templatefile("${path.module}/templates/setup.sh.tftpl", {
    app_name  = var.app_name
    common_bootstrap_content = templatefile("${path.module}/../common/common_bootstrap.sh", {
      username               = var.username
      app_name               = var.app_name
    })
    docker_init_content = file("${path.module}/../common/docker_init.sh")
    docker_compose_content = templatefile("${path.module}/templates/docker-compose.yml.tftpl", {
      elasticsearch_ip  = var.elasticsearch_ip
    })
    prometheus_content     = templatefile("${path.module}/templates/prometheus.yml.tftpl", {
      spring_server_ip = var.spring_ip
      kafka_server_ip  = var.kafka_ip
      mysql_server_ip = var.mysql_ip
    })
    jvm_dashboard_content  = file("${path.module}/templates/grafana-dashboards/jvm-dashboard.json")
    mysql_dashboard_content  = file("${path.module}/templates/grafana-dashboards/mysql-exporter.json")
    kafka_dashboard_content  = file("${path.module}/templates/grafana-dashboards/kafka-exporter.json")
  })
}