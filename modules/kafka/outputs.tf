output "private_ip" {
    value = google_compute_instance.kafka_server.network_interface[0].network_ip
}
