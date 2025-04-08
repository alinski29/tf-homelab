resource "docker_image" "qbittorrent" {
  provider      = docker.rpi
  name          = data.docker_registry_image.qbittorrent.name
  force_remove  = true
  pull_triggers = [data.docker_registry_image.qbittorrent.sha256_digest]
}

resource "docker_container" "qbittorrent" {
  provider     = docker.rpi
  name         = "qbittorrent"
  image        = docker_image.qbittorrent.image_id
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.homelab.name
  }
  restart = "unless-stopped"

  env = [
    "PUID=${var.puid}",
    "PGID=${var.pgid}",
    "TZ=${var.timezone}",
    "WEBUI_PORT=9091",
    "TORRENTING_PORT=51413",
  ]

  ports {
    internal = 9091
    external = 9091
  }
  ports {
    internal = 51413
    external = 51413
    protocol = "tcp"
  }
  ports {
    internal = 51413
    external = 51413
    protocol = "udp"
  }


  volumes {
    host_path      = "${local.pi_docker_volumes_home}/qbittorrent/config"
    container_path = "/config"
  }
  volumes {
    host_path      = "${local.pi_docker_volumes_home}/qbittorrent/downloads"
    container_path = "/downloads/other"
  }
  volumes {
    host_path      = "${local.pi_docker_volumes_home}/media/tv"
    container_path = "/downloads/tv"
  }
  volumes {
    host_path      = "${local.pi_docker_volumes_home}/media/movies"
    container_path = "/downloads/movies"
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.qbittorrent.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.qbittorrent.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.routers.qbittorrent.tls.certresolver"
    value = "duckdns"
  }
  labels {
    label = "traefik.http.routers.qbittorrent.tls.domains[0].main"
    value = var.cert_domain
  }
  labels {
    label = "traefik.http.routers.qbittorrent.tls.domains[0].sans"
    value = "*.${var.cert_domain}"
  }
  labels {
    label = "traefik.http.routers.qbittorrent.rule"
    value = "Host(`torrents.${var.cert_domain}`)"
  }
  labels {
    label = "traefik.http.services.qbittorrent.loadbalancer.server.port"
    value = "9091"
  }

}
