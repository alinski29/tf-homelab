resource "docker_image" "plex_arm64" {
  provider      = docker.rpi
  name          = data.docker_registry_image.plex.name
  platform      = "arm64"
  force_remove  = true
  pull_triggers = [data.docker_registry_image.plex.sha256_digest]

}

resource "docker_container" "plex" {
  provider     = docker.rpi
  name         = "plex"
  image        = docker_image.plex_arm64.image_id
  network_mode = "host"
  restart      = "unless-stopped"

  env = [
    "PUID=${var.puid}",
    "PGID=${var.pgid}",
    "VERSION=docker",
    # PLEX_CLAIM is optional and usually used only once during setup
    # "PLEX_CLAIM=YOUR_CLAIM_TOKEN"
  ]

  volumes {
    host_path      = "${local.pi_docker_volumes_home}/plex/config"
    container_path = "/config"
  }
  volumes {
    host_path      = "${local.pi_docker_volumes_home}/plex/tv"
    container_path = "/tv"
  }
  volumes {
    host_path      = "${local.pi_docker_volumes_home}/plex/movies"
    container_path = "/movies"
  }
}
