output "private_ip" {
    value = google_compute_instance.elasticsearch_server.network_interface[0].network_ip
}
