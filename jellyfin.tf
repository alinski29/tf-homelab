resource "docker_image" "jellyfin_arm64" {
  provider      = docker.rpi
  name          = data.docker_registry_image.jellyfin.name
  platform      = "arm64"
  force_remove  = true
  pull_triggers = [data.docker_registry_image.jellyfin.sha256_digest]
}

resource "docker_container" "jellyfin" {
  provider     = docker.rpi
  name         = "jellyfin"
  image        = docker_image.jellyfin_arm64.image_id
  network_mode = "bridge"
  restart      = "unless-stopped"
  networks_advanced {
    name = docker_network.homelab.name
  }

  ports {
    internal = 8096
    external = 8096
  }

  # HTTPS webUI
  # ports {
  #   internal = 8920
  #   external = 8920
  # }

  # Allow clients to discovery Jellyfin on the local network
  ports {
    internal = 7359
    external = 7359
    protocol = "udp"
  }

  env = [
    "PUID=${var.puid}",
    "PGID=${var.pgid}",
    "TZ=${var.timezone}",
    "VERSION=docker",
  ]

  volumes {
    host_path      = "${local.pi_docker_volumes_home}/media/tv"
    container_path = "/data/tvshows"
  }
  volumes {
    host_path      = "${local.pi_docker_volumes_home}/media/movies"
    container_path = "/data/movies"
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.jellyfin.rule"
    value = "Host(`media.home.lan`)"
  }
  labels {
    label = "traefik.http.routers.jellyfin.entrypoints"
    value = "web"
  }
  labels {
    label = "traefik.http.services.jellyfin.loadbalancer.server.scheme"
    value = "http"
  }
  labels {
    label = "traefik.http.services.jellyfin.loadbalancer.server.port"
    value = "8096"
  }

}
