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

# resource "docker_container" "ollama" {
#   # provider = docker # Default provider (localhost)
#   name    = "ollama"
#   image   = "ollama/ollama:${var.ollama_docker_tag}"
#   restart = "unless-stopped"
#   tty     = true # Keep TTY attached as per compose

#   # pull_policy = "always" # Terraform docker provider manages image pulling implicitly

#   volumes {
#     # Assuming DOCKER_VOLUMES_HOME on localhost might be different,
#     # adjust var.docker_volumes_home default or override if needed.
#     # For now, using the same variable.
#     host_path      = "${var.docker_volumes_home}/ollama"
#     container_path = "/root/.ollama"
#   }
# }
