# logstash 고유 static IP
resource "google_compute_address" "logstash_ip" {
  name = "logstash-static-ip"
}

# logstash VM 인스턴스 정의
resource "google_compute_instance" "logstash_server" {
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
      nat_ip = google_compute_address.logstash_ip.address
    }
  }

  metadata_startup_script = templatefile("${path.module}/templates/setup.sh.tftpl", {
    app_name  = var.app_name
    common_bootstrap_content = templatefile("${path.module}/../common/common_bootstrap.sh", {
      username  = var.username
      app_name  = var.app_name
    })
    docker_init_content = file("${path.module}/../common/docker_init.sh")
    docker_compose_content = file("${path.module}/templates/docker-compose.yml")
    logstash_conf_content = templatefile("${path.module}/templates/logstash.conf.tftpl", {
      environment = var.environment
    })
  })
}
