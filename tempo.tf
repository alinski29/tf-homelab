resource "docker_image" "tempo" {
  name          = data.docker_registry_image.tempo.name
  provider      = docker.rpi
  platform      = "arm64"
  force_remove  = true
  pull_triggers = [data.docker_registry_image.tempo.sha256_digest]
}

resource "null_resource" "tempo_config" {
  triggers = {
    template_file = filesha256("${path.module}/files/tempo/tempo-config.yaml.tpl")
  }

  connection {
    type        = "ssh"
    user        = "pi"
    host        = var.pi_ip_address
    private_key = file("${var.local_home}/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.pi_docker_volumes_home}/tempo"
    ]
  }

  provisioner "file" {
    content = templatefile("${path.module}/files/tempo/tempo-config.yaml.tpl", {
      prometheus_endpoint = "https://prometheus.${var.cert_domain}/api/v1/write"
      prometheus_username = "monitoring"
      prometheus_password = var.prometheus_otel_password

    })
    destination = "${local.pi_docker_volumes_home}/tempo/tempo-config.yaml"
  }
}

resource "docker_container" "tempo" {
  depends_on = [
    null_resource.tempo_config
  ]
  provider     = docker.rpi
  name         = "tempo"
  image        = docker_image.tempo.image_id
  hostname     = "tempo"
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.homelab.name
  }
  restart = "unless-stopped"

  command = [
    "--config.file=/etc/tempo/config.yaml"
  ]

  volumes {
    host_path      = "${local.pi_docker_volumes_home}/tempo/tempo-config.yaml"
    container_path = "/etc/tempo/config.yaml"
  }
  volumes {
    host_path      = "${local.pi_docker_volumes_home}/tempo/data"
    container_path = "/data/tempo"
  }

  log_opts = {
    tag = "{{.Name}}|{{.ID}}"
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }
  // --- Router and Service for database connection using tempo subdomain ---
  labels {
    label = "traefik.http.routers.tempo-ui.rule"
    value = "Host(`tempo.${var.cert_domain}`)"
  }
  labels {
    label = "traefik.http.routers.tempo-ui.middlewares"
    value = "tempo-auth@file"
  }
  labels {
    label = "traefik.http.routers.tempo-ui.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.tempo-ui.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.routers.tempo-ui.tls.certresolver"
    value = "duckdns"
  }
  labels {
    label = "traefik.http.routers.tempo-ui.tls.domains[0].main"
    value = var.cert_domain
  }
  labels {
    label = "traefik.http.routers.tempo-ui.tls.domains[0].sans"
    value = "*.${var.cert_domain}"
  }
  labels {
    label = "traefik.http.routers.tempo-ui.service"
    value = "tempo-ui"
  }
  labels {
    label = "traefik.http.services.tempo-ui.loadbalancer.server.port"
    value = "3200"
  }

  // --- Router and Service for GRPC (Port 4417) using tempo-grpc subdomain ---
  labels {
    label = "traefik.http.routers.tempo-grpc.rule"
    value = "Host(`tempo-grpc.${var.cert_domain}`)"
  }
  labels {
    label = "traefik.http.routers.tempo-grpc.middlewares"
    value = "tempo-auth@file"
  }
  labels {
    label = "traefik.http.routers.tempo-grpc.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.routers.tempo-grpc.service"
    value = "tempo-grpc"
  }
  labels {
    label = "traefik.http.routers.tempo-grpc.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.tempo-grpc.tls.certresolver"
    value = "duckdns"
  }
  labels {
    label = "traefik.http.routers.tempo-grpc.tls.domains[0].main"
    value = var.cert_domain
  }
  labels {
    label = "traefik.http.routers.tempo-grpc.tls.domains[0].sans"
    value = "*.${var.cert_domain}"
  }
  labels {
    label = "traefik.http.services.tempo-grpc.loadbalancer.server.port"
    value = "4417"
  }
  labels {
    label = "traefik.http.services.tempo-grpc.loadbalancer.server.scheme"
    value = "h2c"
  }

  // --- Router and Service for HTTP (Port 4418) using tempo-http subdomain ---
  labels {
    label = "traefik.http.routers.tempo-http.rule"
    value = "Host(`tempo-http.${var.cert_domain}`)"
  }
  labels {
    label = "traefik.http.routers.tempo-http.middlewares"
    value = "tempo-auth@file"
  }
  labels {
    label = "traefik.http.routers.tempo-http.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.routers.tempo-http.service"
    value = "tempo-http"
  }
  labels {
    label = "traefik.http.routers.tempo-http.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.tempo-http.tls.certresolver"
    value = "duckdns"
  }
  labels {
    label = "traefik.http.routers.tempo-http.tls.domains[0].main"
    value = var.cert_domain
  }
  labels {
    label = "traefik.http.routers.tempo-http.tls.domains[0].sans"
    value = "*.${var.cert_domain}"
  }
  labels {
    label = "traefik.http.services.tempo-http.loadbalancer.server.port"
    value = "4418"
  }
  labels {
    label = "traefik.http.services.tempo-http.loadbalancer.server.scheme"
    value = "http"
  }
}
