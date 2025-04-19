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

  env = [
    "PUID=${var.puid}",
    "PGID=${var.pgid}",
    "TZ=${var.timezone}",
    "VERSION=docker",
  ]

  volumes {
    host_path      = "${local.pi_docker_volumes_home}/jellyfin/config"
    container_path = "/config"
  }

  volumes {
    host_path      = "${local.pi_docker_volumes_home}/media/tv"
    container_path = "/data/tvshows"
  }
  volumes {
    host_path      = "${local.pi_docker_volumes_home}/media/movies"
    container_path = "/data/movies"
  }

  log_opts = {
    tag = "{{.Name}}|{{.ID}}"
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.jellyfin-secure.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.jellyfin-secure.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.routers.jellyfin-secure.tls.certresolver"
    value = "duckdns"
  }
  labels {
    label = "traefik.http.routers.jellyfin-secure.tls.domains[0].main"
    value = var.cert_domain
  }
  labels {
    label = "traefik.http.routers.jellyfin-secure.tls.domains[0].sans"
    value = "*.${var.cert_domain}"
  }
  labels {
    label = "traefik.http.routers.jellyfin-secure.rule"
    value = "Host(`media.${var.cert_domain}`)"
  }
  labels {
    label = "traefik.http.services.jellyfin-secure.loadBalancer.server.port"
    value = "8096"
  }
}
