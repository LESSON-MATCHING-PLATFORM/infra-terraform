output "private_ip" {
    value = google_compute_instance.mysql_server.network_interface[0].network_ip
}
