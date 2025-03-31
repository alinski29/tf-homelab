resource "docker_image" "pihole_arm64" {
  provider      = docker.rpi
  name          = data.docker_registry_image.pihole.name
  platform      = "arm64"
  force_remove  = true
  pull_triggers = [data.docker_registry_image.pihole.sha256_digest]
}

resource "docker_container" "pihole" {
  provider     = docker.rpi
  name         = "pihole"
  image        = docker_image.pihole_arm64.image_id
  network_mode = "bridge"
  restart      = "unless-stopped"

  dns = ["127.0.0.1", "1.1.1.1"]

  # Capabilities needed by Pi-hole
  capabilities {
    add = ["NET_ADMIN"]
  }

  env = [
    "TZ=${var.timezone}",
    "WEBPASSWORD=${var.pihole_webpassword}"
  ]

  ports {
    internal = 53
    external = 53
    protocol = "tcp"
  }
  ports {
    internal = 53
    external = 53
    protocol = "udp"
  }
  ports {
    internal = 67
    external = 67
    protocol = "udp"
  }
  ports {
    internal = 80
    external = 80
    protocol = "tcp"
  }
  ports {
    internal = 443
    external = 443
    protocol = "tcp"
  }

  volumes {
    host_path      = "${local.pi_docker_volumes_home}/pihole/etc-pihole"
    container_path = "/etc/pihole"
    read_only      = false
  }
  volumes {
    host_path      = "${local.pi_docker_volumes_home}/pihole/etc-dnsmasq.d"
    container_path = "/etc/dnsmasq.d"
    read_only      = false
  }
}
