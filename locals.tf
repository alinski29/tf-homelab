locals {
  pi_docker_volumes_home    = replace(var.docker_volumes_home, "~/", "${var.pi_home}/")
  local_docker_volumes_home = replace(var.docker_volumes_home, "~/", "${var.local_home}/")
}
