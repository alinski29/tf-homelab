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
