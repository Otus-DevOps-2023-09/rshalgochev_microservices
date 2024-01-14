output "gitlab_external_address" {
  value = yandex_compute_instance.gitlab-server.network_interface.0.nat_ip_address
}
