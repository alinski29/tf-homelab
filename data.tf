data "docker_registry_image" "syncthing" {
  name = "ghcr.io/linuxserver/syncthing"
}

data "docker_registry_image" "pihole" {
  name = "pihole/pihole"
}

data "docker_registry_image" "kestra" {
  name = "kestra/kestra"
}

data "docker_registry_image" "ollama" {
  name = "ollama/ollama"
}

data "docker_registry_image" "openwebui" {
  name = "ghcr.io/open-webui/open-webui"
}

data "docker_registry_image" "traefik" {
  name = "traefik:3.3.5"
}

data "docker_registry_image" "qbittorrent" {
  name = "linuxserver/qbittorrent"
}

data "docker_registry_image" "jellyfin" {
  name = "linuxserver/jellyfin"
}
