resource "docker_image" "kestra_postgres" {
  provider     = docker.rpi
  name         = "postgres:17.4"
  force_remove = true
}

resource "docker_image" "kestra" {
  provider      = docker.rpi
  name          = data.docker_registry_image.kestra.name
  force_remove  = true
  pull_triggers = [data.docker_registry_image.kestra.sha256_digest]
}

resource "docker_network" "kestra" {
  provider = docker.rpi
  name     = "kestra"
  driver   = "bridge"
}

resource "docker_volume" "kestra" {
  provider = docker.rpi
  driver   = "local"
  name     = "kestra_kestra-data"

  labels {
    label = "com.docker.compose.project"
    value = "kestra"
  }
  labels {
    label = "com.docker.compose.version"
    value = "2.33.1"
  }
  labels {
    label = "com.docker.compose.volume"
    value = "kestra-data"
  }
  labels {
    label = "com.docker.compose.config-hash"
    value = "d480bda53aef8fa2da0ad95978bed24ce806bc320174dd5eae676b992b8a3f14"
  }
}

resource "docker_volume" "kestra_postgres" {
  provider = docker.rpi
  driver   = "local"
  name     = "kestra_postgres-data" # Updated name to match existing volume

  # Added labels from terraform plan diff
  labels {
    label = "com.docker.compose.config-hash"
    value = "f3963baf44a4ddffa7338eca719efb746b734619e783fec5cd66873f31213613"
  }
  labels {
    label = "com.docker.compose.project"
    value = "kestra"
  }
  labels {
    label = "com.docker.compose.version"
    value = "2.33.1"
  }
  labels {
    label = "com.docker.compose.volume"
    value = "postgres-data"
  }
}

resource "docker_container" "kestra_postgres" {
  provider     = docker.rpi
  name         = "kestra-postgres"
  image        = docker_image.kestra_postgres.image_id
  hostname     = "kestra-postgres"
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.kestra.name
  }
  restart = "unless-stopped"
  env = [
    "POSTGRES_DB=kestra",
    "POSTGRES_USER=${var.kestra_db_username}",
    "POSTGRES_PASSWORD=${var.kestra_db_password}"
  ]

  volumes {
    volume_name    = docker_volume.kestra_postgres.name
    container_path = "/var/lib/postgresql/data"
  }

  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -d kestra -U ${var.kestra_db_username}"]
    interval = "30s"
    timeout  = "10s"
    retries  = 10
  }

  log_opts = {
    tag = "{{.Name}}|{{.ID}}"
  }
}

resource "null_resource" "kestra_config_upload" {
  triggers = {
    template_file = filesha256("${path.module}/files/kestra/kestra-config.yml.tpl")
    db_password   = var.kestra_db_password
  }

  connection {
    type        = "ssh"
    user        = "pi"
    host        = var.pi_ip_address
    private_key = file("${var.local_home}/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${var.pi_home}/.config"
    ]
  }

  provisioner "file" {
    content = templatefile("${path.module}/files/kestra/kestra-config.yml.tpl", {
      db_username = var.kestra_db_username
      db_password = var.kestra_db_password
      db_hostname = "kestra-postgres"
      db_port     = "5432"
    })
    destination = "${var.pi_home}/.config/kestra-config.yml"
  }
}

resource "docker_container" "kestra" {
  depends_on = [
    docker_container.kestra_postgres,
    null_resource.kestra_config_upload # Ensure config is uploaded first
  ]
  provider     = docker.rpi
  name         = "kestra"
  image        = docker_image.kestra.image_id
  hostname     = "kestra"
  network_mode = "bridge"
  restart      = "unless-stopped"
  networks_advanced {
    name = docker_network.kestra.name
  }
  networks_advanced {
    name = docker_network.homelab.name
  }

  entrypoint = ["/bin/bash"]
  command    = ["-c", "/app/kestra server standalone --worker-thread=128 -c /etc/config/config.yaml"]
  user       = "root"

  env = [
    "SECRET_YAHOOFINANCE_TOKEN=${base64encode(var.yahoofinance_token)}",
  ]

  volumes {
    volume_name    = docker_volume.kestra.name
    container_path = "/app/storage"
  }
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
  volumes {
    host_path      = "/tmp/kestra-wd"
    container_path = "/tmp/kestra-wd"
  }
  volumes {
    host_path      = "${var.pi_home}/.config/kestra-config.yml"
    container_path = "/etc/config/config.yaml"
    read_only      = true
  }

  log_opts = {
    tag = "{{.Name}}|{{.ID}}"
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.kestra.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.kestra.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.routers.kestra.tls.certresolver"
    value = "duckdns"
  }
  labels {
    label = "traefik.http.routers.kestra.tls.domains[0].main"
    value = var.cert_domain
  }
  labels {
    label = "traefik.http.routers.kestra.tls.domains[0].sans"
    value = "*.${var.cert_domain}"
  }
  labels {
    label = "traefik.http.routers.kestra.rule"
    value = "Host(`kestra.${var.cert_domain}`)"
  }
  labels {
    label = "traefik.http.services.kestra.loadbalancer.server.port"
    value = "8080"
  }
}
