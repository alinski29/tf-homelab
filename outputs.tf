output "syncthing_pi_container_id" {
  value = docker_container.syncthing_pi.id
}

output "syncthing_local_container_id" {
  value = docker_container.syncthing_local.id
}

output "pihole_local_container_id" {
  value = docker_container.pihole.id
}

output "kestra_container_id" {
  value = docker_container.kestra.id
}

output "kestra_postgres_container_id" {
  value = docker_container.kestra_postgres.id
}

# output "ollama_container_id" {
#   value = docker_container.ollama.id
# }

# output "openwebui_container_id" {
#   value = docker_container.openwebui.id
# }

output "traefik_container_id" {
  value = docker_container.traefik.id
}

output "qbittorrent_container_id" {
  value = docker_container.qbittorrent.id
}

output "jellyfin_container_id" {
  value = docker_container.jellyfin.id
}

output "cadvisor_container_id" {
  value = docker_container.cadvisor.id
}

output "grafana_container_id" {
  value = docker_container.grafana.id
}

output "loki_container_id" {
  value = docker_container.loki.id
}

output "otelcol_container_id" {
  value = docker_container.otelcol.id
}

output "prometheus_container_id" {
  value = docker_container.prometheus.id
}

# output "pgadmin_container_id" {
#   value = docker_container.pgadmin_local.id
# }
