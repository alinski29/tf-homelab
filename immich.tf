resource "docker_image" "immich" {
  provider      = docker.rpi
  name          = data.docker_registry_image.immich.name
  platform      = "arm64"
  force_remove  = true
  pull_triggers = [data.docker_registry_image.immich.sha256_digest]
}

resource "docker_image" "immich_postgres" {
  provider      = docker.rpi
  name          = data.docker_registry_image.immich_postgres.name
  platform      = "arm64"
  force_remove  = true
  pull_triggers = [data.docker_registry_image.immich_postgres.sha256_digest]
}

resource "docker_image" "immich_redis" {
  provider     = docker.rpi
  name         = data.docker_registry_image.immich_redis.name
  platform     = "arm64"
  force_remove = true
}

resource "docker_image" "immich_ml_x64" {
  provider      = docker.local
  name          = data.docker_registry_image.immich_ml.name
  force_remove  = true
  pull_triggers = [data.docker_registry_image.immich_ml.sha256_digest]
}

resource "docker_network" "immich" {
  provider = docker.rpi
  name     = "immich"
  driver   = "bridge"
}

resource "docker_container" "immich" {
  depends_on = [
    docker_container.immich_postgres,
    docker_container.immich_redis,
    docker_container.immich_ml_local
  ]
  provider     = docker.rpi
  name         = "immich"
  image        = docker_image.immich.image_id
  hostname     = "immich"
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.immich.name
  }
  networks_advanced {
    name = docker_network.homelab.name
  }
  restart = "unless-stopped"

  ports {
    internal = 2283
    external = 2283
  }

  volumes {
    host_path      = "${local.pi_docker_volumes_home}/immich/data"
    container_path = "/data"
  }
  volumes {
    host_path      = "/etc/localtime"
    container_path = "/etc/localtime"
    read_only      = true
  }
  volumes {
    host_path      = "${var.pi_home}/syncthing/Camera/Camera"
    container_path = "/mnt/syncthing/Camera"
  }
  volumes {
    host_path      = "${var.pi_home}/syncthing/Photos"
    container_path = "/mnt/syncthing/Photos"
  }
  volumes {
    host_path      = "${var.pi_home}/syncthing/FP4Pictures"
    container_path = "/mnt/syncthing/FP4Pictures"
  }
  volumes {
    host_path      = "${var.pi_home}/syncthing/FP4InstagramVideos"
    container_path = "/mnt/syncthing/FP4InstagramVideos"
  }

  env = [
    "IMMICH_VERSION=release",
    "DB_URL=postgresql://immich:${var.immich_postgres_password}@immich-postgres:5432/immich",
    "DB_HOSTNAME=immich-postgres",
    "DB_USERNAME=immich",
    "DB_DATABASE_NAME=immich",
    "DB_PASSWORD=${var.immich_postgres_password}",
    "REDIS_URL=redis://immich-redis:6379",
    "REDIS_HOSTNAME=immich-redis",
  ]

  log_opts = {
    tag = "{{.Name}}|{{.ID}}"
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.immich.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.immich.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.routers.immich.tls.certresolver"
    value = "duckdns"
  }
  labels {
    label = "traefik.http.routers.immich.tls.domains[0].main"
    value = var.cert_domain
  }
  labels {
    label = "traefik.http.routers.immich.tls.domains[0].sans"
    value = "*.${var.cert_domain}"
  }
  labels {
    label = "traefik.http.routers.immich.rule"
    value = "Host(`immich.${var.cert_domain}`)"
  }
  labels {
    label = "traefik.http.services.immich.loadbalancer.server.port"
    value = "2283"
  }
}


resource "docker_container" "immich_postgres" {
  provider     = docker.rpi
  name         = "immich-postgres"
  image        = docker_image.immich_postgres.image_id
  hostname     = "immich-postgres"
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.immich.name
  }
  restart  = "unless-stopped"
  shm_size = 256
  volumes {
    host_path      = "${local.pi_docker_volumes_home}/immich/db"
    container_path = "/var/lib/postgresql/data"
  }
  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -d immich -U immich"]
    interval = "30s"
    timeout  = "10s"
    retries  = 10
  }
  env = [
    "POSTGRES_PASSWORD=${var.immich_postgres_password}",
    "POSTGRES_USER=immich",
    "POSTGRES_DB=immich",
    "POSTGRES_INITDB_ARGS=--data-checksums",
  ]
  log_opts = {
    tag = "{{.Name}}|{{.ID}}"
  }
}

resource "docker_container" "immich_redis" {
  provider     = docker.rpi
  name         = "immich-redis"
  image        = docker_image.immich_redis.image_id
  hostname     = "immich-redis"
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.immich.name
  }
  healthcheck {
    test     = ["CMD", "redis-cli", "ping"]
    interval = "30s"
    timeout  = "10s"
    retries  = 10
  }
  log_opts = {
    tag = "{{.Name}}|{{.ID}}"
  }
}

resource "docker_container" "immich_ml_local" {
  provider     = docker.local
  name         = "immich-ml"
  image        = docker_image.immich_ml_x64.image_id
  hostname     = "immich-ml"
  network_mode = "bridge"
  restart      = "unless-stopped"

  ports {
    internal = 3003
    external = 3003
  }

  volumes {
    host_path      = "${local.local_docker_volumes_home}/immich/ml"
    container_path = "/cache"
  }
}
