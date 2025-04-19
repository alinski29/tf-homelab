resource "docker_image" "cadvisor" {
  name          = data.docker_registry_image.cadvisor.name
  provider      = docker.rpi
  platform      = "arm64"
  force_remove  = true
  pull_triggers = [data.docker_registry_image.cadvisor.sha256_digest]
}

resource "docker_container" "cadvisor" {
  provider     = docker.rpi
  name         = "cadvisor"
  hostname     = "cadvisor"
  image        = docker_image.cadvisor.image_id
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.homelab.name
  }
  restart    = "unless-stopped"
  privileged = true

  command = [
    "--allow_dynamic_housekeeping=true",
    "--global_housekeeping_interval=1m0s",
    "--housekeeping_interval=10s"
  ]

  volumes {
    host_path      = "/"
    container_path = "/rootfs"
    read_only      = true
  }

  volumes {
    host_path      = "/var/run"
    container_path = "/var/run"
    read_only      = true
  }

  volumes {
    host_path      = "/sys"
    container_path = "/sys"
    read_only      = true
  }

  volumes {
    host_path      = "/var/lib/docker"
    container_path = "/var/lib/docker"
    read_only      = true
  }

  volumes {
    host_path      = "/dev/disk"
    container_path = "/dev/disk"
    read_only      = true
  }

  log_opts = {
    tag = "{{.Name}}|{{.ID}}"
  }

}
