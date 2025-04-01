resource "docker_image" "ollama" {
  provider     = docker.local
  name         = data.docker_registry_image.ollama.name
  force_remove = true
}

resource "docker_image" "openwebui" {
  provider     = docker.local
  name         = data.docker_registry_image.openwebui.name
  force_remove = true
}

resource "docker_network" "openwebui" {
  provider = docker.local
  name     = "openwebui"
  driver   = "bridge"
}

resource "docker_container" "ollama" {
  provider     = docker.local
  name         = "ollama"
  image        = docker_image.ollama.image_id
  restart      = "unless-stopped"
  hostname     = "ollama"
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.openwebui.name
  }

  volumes {
    host_path      = "${local.local_docker_volumes_home}/ollama"
    container_path = "/root/.ollama"
  }
}

resource "docker_container" "openwebui" {
  provider = docker.local
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

  ports {
    internal = 8080
    external = var.openwebui_port
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
  volumes {
    host_path      = "${local.local_docker_volumes_home}/open-webui/app/backend/data"
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
}
