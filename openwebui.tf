resource "docker_image" "ollama" {
  provider      = docker.rpi
  name          = data.docker_registry_image.ollama.name
  platform      = "arm64"
  force_remove  = true
  pull_triggers = [data.docker_registry_image.ollama.sha256_digest]
}

resource "docker_image" "openwebui" {
  provider      = docker.rpi
  name          = data.docker_registry_image.openwebui.name
  platform      = "arm64"
  force_remove  = true
  pull_triggers = [data.docker_registry_image.openwebui.sha256_digest]
}

resource "docker_network" "openwebui" {
  provider = docker.rpi
  name     = "openwebui"
  driver   = "bridge"
}

resource "docker_container" "ollama" {
  provider     = docker.rpi
  name         = "openwebui-ollama"
  image        = docker_image.ollama.image_id
  restart      = "unless-stopped"
  hostname     = "ollama"
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.openwebui.name
  }

  volumes {
    host_path      = "${local.pi_docker_volumes_home}/ollama"
    container_path = "/root/.ollama"
  }
}

resource "docker_container" "openwebui" {
  provider = docker.rpi
  depends_on = [
    docker_container.ollama
  ]

  name         = "openwebui"
  image        = docker_image.openwebui.image_id
  restart      = "unless-stopped"
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.openwebui.name
  }
  networks_advanced {
    name = docker_network.homelab.name
  }

  ports {
    internal = 8080
    external = var.openwebui_port
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
  volumes {
    host_path      = "${local.pi_docker_volumes_home}/open-webui/app/backend/data"
    container_path = "/app/backend/data"
  }

  env = [
    "ENABLE_OLLAMA_API=true",
    "OLLAMA_BASE_URL=http://${docker_container.ollama.hostname}:11434",
    "ENABLE_OPENAI_API=true",
    "OPENAI_API_KEY=${var.openai_api_key}",
    "ANTHROPIC_API_KEY=${var.anthropic_api_key}",
    "GOOGLE_API_KEY=${var.google_api_key}"
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.openwebui.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.openwebui.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.routers.openwebui.tls.certresolver"
    value = "duckdns"
  }
  labels {
    label = "traefik.http.routers.openwebui.tls.domains[0].main"
    value = var.cert_domain
  }
  labels {
    label = "traefik.http.routers.openwebui.tls.domains[0].sans"
    value = "*.${var.cert_domain}"
  }
  labels {
    label = "traefik.http.routers.openwebui.rule"
    value = "Host(`ai.${var.cert_domain}`)"
  }
}
