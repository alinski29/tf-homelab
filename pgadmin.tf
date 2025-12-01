# resource "docker_image" "pgadmin_x64" {
#   provider      = docker.local
#   name          = data.docker_registry_image.pgadmin.name
#   force_remove  = true
#   pull_triggers = [data.docker_registry_image.pgadmin.sha256_digest]
# }

# resource "docker_container" "pgadmin_local" {
#   provider     = docker.local
#   name         = "pgadmin"
#   image        = docker_image.pgadmin_x64.image_id
#   hostname     = "pgadmin"
#   restart      = "unless-stopped"
#   network_mode = "host"

#   env = [
#     "PUID=${var.puid}",
#     "PGID=100",
#     "TZ=${var.timezone}",
#     "PGADMIN_LISTEN_PORT=8888",
#     "PGADMIN_DEFAULT_EMAIL=admin@admin.com",
#     "PGADMIN_DEFAULT_PASSWORD=admin"
#   ]

#   volumes {
#     host_path      = "${local.local_docker_volumes_home}/pgadmin"
#     container_path = "/var/lib/pgadmin"
#   }

#   log_opts = {
#     tag = "{{.Name}}|{{.ID}}"
#   }

# }
