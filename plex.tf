# resource "docker_image" "plex_arm64" {
#   provider      = docker.rpi
#   name          = data.docker_registry_image.plex.name
#   platform      = "arm64"
#   force_remove  = true
#   pull_triggers = [data.docker_registry_image.plex.sha256_digest]
# }

# resource "docker_container" "plex" {
#   provider     = docker.rpi
#   name         = "plex"
#   image        = docker_image.plex_arm64.image_id
#   network_mode = "bridge"
#   restart      = "unless-stopped"
#   networks_advanced {
#     name = docker_network.homelab.name
#   }

#   ports {
#     internal = 32400
#     external = 32400
#     protocol = "tcp"
#   }

#   env = [
#     "PUID=${var.puid}",
#     "PGID=${var.pgid}",
#     "VERSION=docker",
#   ]

#   volumes {
#     host_path      = "${local.pi_docker_volumes_home}/plex/config"
#     container_path = "/config"
#   }
#   volumes {
#     host_path      = "${local.pi_docker_volumes_home}/plex/tv"
#     container_path = "/tv"
#   }
#   volumes {
#     host_path      = "${local.pi_docker_volumes_home}/plex/movies"
#     container_path = "/movies"
#   }

#   # labels {
#   #   label = "traefik.enable"
#   #   value = "true"
#   # }
#   # labels {
#   #   label = "traefik.http.routers.plex.rule"
#   #   value = "Host(`media.home.lan`)"
#   # }
#   # labels {
#   #   label = "traefik.http.routers.plex.entrypoints"
#   #   value = "web"
#   # }
#   # labels {
#   #   label = "traefik.http.services.plex.loadbalancer.server.scheme"
#   #   value = "http"
#   # }
#   # labels {
#   #   label = "traefik.http.routers.plex.service"
#   #   value = "plex"
#   # }
#   # labels {
#   #   label = "traefik.http.services.plex.loadbalancer.server.port"
#   #   value = "32400"
#   # }
# }
