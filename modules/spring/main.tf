# Spring 고유 static IP
resource "google_compute_address" "spring_ip" {
  name = var.static_ip_name
}

# Spring VM 인스턴스 정의
resource "google_compute_instance" "spring_server" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = var.target_tags

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.spring_ip.address
    }
  }

  metadata_startup_script = templatefile("${path.module}/templates/setup.sh.tftpl", {
    app_name = var.app_name
    common_bootstrap_content = templatefile("${path.module}/../common/common_bootstrap.sh", {
      username = var.username
      app_name = var.app_name
    })
    docker_init_content = file("${path.module}/../common/docker_init.sh")
    docker_compose_content = templatefile("${path.module}/templates/docker-compose.yml.tftpl", {
      spring_server_image = var.spring_server_image
      spring_environment  = var.spring_environment
    })
    filebeat_yml_content = templatefile("${path.module}/templates/filebeat.yml.tftpl", {
      logstash_ip = var.logstash_ip
      service     = var.instance_name
      environment = var.environment
    })
  })

  service_account {
    email  = var.service_account_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
