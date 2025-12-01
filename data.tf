data "docker_registry_image" "syncthing" {
  name = "ghcr.io/linuxserver/syncthing"
}

data "docker_registry_image" "pihole" {
  name = "pihole/pihole"
}

data "docker_registry_image" "kestra" {
  name = "kestra/kestra"
}

data "docker_registry_image" "ollama" {
  name = "ollama/ollama"
}

# data "docker_registry_image" "openwebui" {
#   name = "ghcr.io/open-webui/open-webui"
# }

data "docker_registry_image" "traefik" {
  name = "traefik:3.3.5"
}

data "docker_registry_image" "qbittorrent" {
  name = "linuxserver/qbittorrent"
}

data "docker_registry_image" "jellyfin" {
  name = "linuxserver/jellyfin"
}

data "docker_registry_image" "cadvisor" {
  name = "gcr.io/cadvisor/cadvisor"
}

data "docker_registry_image" "grafana" {
  name = "grafana/grafana"
}

data "docker_registry_image" "prometheus" {
  name = "prom/prometheus"
}

data "docker_registry_image" "otelcol" {
  name = "otel/opentelemetry-collector-contrib"
}

data "docker_registry_image" "loki" {
  name = "grafana/loki"
}

data "docker_registry_image" "tempo" {
  name = "grafana/tempo"
}

# data "docker_registry_image" "pgadmin" {
#   name = "dpage/pgadmin4"
# }

data "docker_registry_image" "immich" {
  name = "ghcr.io/immich-app/immich-server:release"
}

data "docker_registry_image" "immich_postgres" {
  name = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0"
}

data "docker_registry_image" "immich_redis" {
  name = "valkey/valkey:8-bookworm"
}

data "docker_registry_image" "immich_ml" {
  name = "ghcr.io/immich-app/immich-machine-learning:release"
}

# data "cloudflare_zone" "duckdns" {
#   zone_id = "81870ecbc3d1e7b5742013d7c836759a"
#   # filter = {
#   #   name = "duckdns.org"
#   # }
# }
