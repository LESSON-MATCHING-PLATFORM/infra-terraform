locals {
  firewall_rules = {
    "ssh"               = { ports = ["22"],             tags = ["ssh"]}
    "kafka"             = { ports = ["9092", "9094"],   tags = ["kafka-node"] }
    "kafka-exporter"    = { ports = ["9308"],           tags = ["kafka-exporter"]}
    "mysql"             = { ports = ["3306"],           tags = ["mysql-node"] }
    "mysql-exporter"    = { ports = ["9104"],           tags = ["mysqld-exporter"] }
    "spring"            = { ports = ["8080"],           tags = ["spring-node"] }
    "node-exporter"     = { ports = ["9100"],           tags = ["node-exporter"] }
    "logstash"          = { ports = ["5044"],           tags = ["logstash"]}
    "elasticsearch"     = { ports = ["9200"],           tags = ["elasticsearch"]}
    "prometheus"        = { ports = ["9090"],           tags = ["prometheus"]}
    "grafana"           = { ports = ["3000"],           tags = ["grafana"]}
    "kibana"            = { ports = ["5601"],           tags = ["kibana"]}
  }
}

resource "google_compute_firewall" "service_firewalls" {
  for_each = local.firewall_rules

  name    = "allow-${each.key}-ports"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = each.value.ports
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = each.value.tags
}