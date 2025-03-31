resource "docker_image" "syncthing_x64" {
  provider      = docker.local
  name          = data.docker_registry_image.syncthing.name
  force_remove  = true
  pull_triggers = [data.docker_registry_image.syncthing.sha256_digest]
}

resource "docker_image" "syncthing_arm64" {
  provider      = docker.rpi
  name          = data.docker_registry_image.syncthing.name
  platform      = "arm64"
  force_remove  = true
  pull_triggers = [data.docker_registry_image.syncthing.sha256_digest]
}


resource "docker_container" "syncthing_local" {
  provider     = docker.local
  name         = "syncthing"
  image        = docker_image.syncthing_x64.image_id
  hostname     = "syncthing"
  restart      = "unless-stopped"
  network_mode = "bridge"

  env = [
    "PUID=${var.puid}",
    "PGID=100",
    "TZ=${var.timezone}"
  ]

  ports {
    internal = 8384
    external = 8384
  }
  ports {
    internal = 22000
    external = 22000
  }
  ports {
    internal = 21027
    external = 21027
    protocol = "udp"
  }

  volumes {
    host_path      = "${local.local_docker_volumes_home}/syncthing/config"
    container_path = "/config"
  }
  volumes {
    host_path      = var.local_home
    container_path = var.local_home
  }
}

resource "docker_container" "syncthing_pi" {
  provider     = docker.rpi
  name         = "syncthing"
  image        = docker_image.syncthing_arm64.image_id
  hostname     = "syncthing"
  restart      = "unless-stopped"
  network_mode = "bridge"

  env = [
    "PUID=${var.puid}",
    "PGID=100",
    "TZ=${var.timezone}"
  ]

  ports {
    internal = 8384
    external = 8384
  }
  ports {
    internal = 22000
    external = 22000
  }
  ports {
    internal = 21027
    external = 21027
    protocol = "udp"
  }

  volumes {
    host_path      = "${local.pi_docker_volumes_home}/syncthing/config"
    container_path = "/config"
  }
  volumes {
    host_path      = var.pi_home
    container_path = var.pi_home
  }
}
