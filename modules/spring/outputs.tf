output "private_ip" {
    value = google_compute_instance.spring_server.network_interface[0].network_ip
}
