data "docker_registry_image" "syncthing" {
  name = "ghcr.io/linuxserver/syncthing"
}

data "docker_registry_image" "pihole" {
  name = "pihole/pihole"
}

data "docker_registry_image" "plex" {
  name = "linuxserver/plex"
}

data "docker_registry_image" "kestra" {
  name = "kestra/kestra"
}

data "docker_registry_image" "transmission" {
  name = "linuxserver/transmission"
}

data "docker_registry_image" "ollama" {
  name = "ollama/ollama"
}

data "docker_registry_image" "openwebui" {
  name = "ghcr.io/open-webui/open-webui"
}
