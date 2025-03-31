resource "docker_image" "transmission" {
  provider      = docker.rpi
  name          = data.docker_registry_image.transmission.name
  force_remove  = true
  pull_triggers = [data.docker_registry_image.transmission.sha256_digest]
}

resource "docker_container" "transmission" {
  provider     = docker.rpi
  name         = "transmission"
  image        = docker_image.transmission.image_id
  network_mode = "bridge"
  restart      = "unless-stopped"

  env = [
    "PUID=${var.puid}",
    "PGID=${var.pgid}",
    "TZ=${var.timezone}",
    "USER=${var.transmission_username}",
    "PASS=${var.transmission_password}",
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
    host_path      = "${local.pi_docker_volumes_home}/transmission/config"
    container_path = "/config"
  }
  volumes {
    host_path      = "${local.pi_docker_volumes_home}/transmission/downloads"
    container_path = "/downloads"
  }
  volumes {
    host_path      = "${local.pi_docker_volumes_home}/transmission/watch"
    container_path = "/watch"
  }
}
