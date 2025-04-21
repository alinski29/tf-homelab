resource "docker_image" "otelcol" {
  name          = data.docker_registry_image.otelcol.name
  provider      = docker.rpi
  platform      = "arm64"
  force_remove  = true
  pull_triggers = [data.docker_registry_image.otelcol.sha256_digest]
}

resource "null_resource" "otel_config" {
  triggers = {
    template_file = filesha256("${path.module}/files/otel/otel-config.yaml.tpl")
  }

  connection {
    type        = "ssh"
    user        = "pi"
    host        = var.pi_ip_address
    private_key = file("${var.local_home}/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.pi_docker_volumes_home}/otel"
    ]
  }

  provisioner "file" {
    content = templatefile("${path.module}/files/otel/otel-config.yaml.tpl", {
      cadvisor_url           = "cadvisor:8080",
      loki_url               = "https://loki.${var.cert_domain}",
      loki_auth_header       = "${local.loki_otel_auth_header}",
      prometheus_url         = "https://prometheus.${var.cert_domain}",
      prometheus_auth_header = "${local.prometheus_otel_auth_header}",
      hostname               = "pi"
    })
    destination = "${local.pi_docker_volumes_home}/otel/otel-config.yaml"
  }
}

resource "docker_container" "otelcol" {
  depends_on = [
    null_resource.otel_config
  ]
  provider     = docker.rpi
  name         = "otelcol"
  image        = docker_image.otelcol.image_id
  hostname     = "otelcol"
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.homelab.name
  }
  restart = "unless-stopped"

  env = [
    "LOKI_AUTH_HEADER=${local.loki_otel_auth_header}",
    "PROMETHEUS_AUTH_HEADER=${local.prometheus_otel_auth_header}",
  ]

  command = [
    "--config=/etc/otelcol/config.yaml",
    "--feature-gates",
    "service.profilesSupport"
    # "--set=service.name=otelcol"
  ]

  volumes {
    host_path      = "${local.pi_docker_volumes_home}/otel/otel-config.yaml"
    container_path = "/etc/otelcol/config.yaml"
  }
  volumes {
    host_path      = "/var/lib/docker/containers"
    container_path = "/var/lib/docker/containers"
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
    label = "traefik.http.routers.otel-grpc-http.rule"
    value = "Host(`otel-grpc.${var.cert_domain}`)"
  }
  labels {
    label = "traefik.http.routers.otel-grpc.middlewares"
    value = "otel-auth@file"
  }
  labels {
    label = "traefik.http.routers.otel-grpc-http.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.routers.otel-grpc-http.service"
    value = "otel-grpc"
  }
  labels {
    label = "traefik.http.routers.otel-grpc-http.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.otel-grpc-http.tls.certresolver"
    value = "duckdns"
  }
  labels {
    label = "traefik.http.routers.otel-grpc-http.tls.domains[0].main"
    value = var.cert_domain
  }
  labels {
    label = "traefik.http.routers.otel-grpc-http.tls.domains[0].sans"
    value = "*.${var.cert_domain}"
  }
  labels {
    label = "traefik.http.services.otel-grpc.loadbalancer.server.port"
    value = "4317"
  }
  labels {
    label = "traefik.http.services.otel-grpc.loadbalancer.server.scheme"
    value = "h2c"
  }

  // --- Router and Service for HTTP (Port 4318) using otel-http subdomain ---
  labels {
    label = "traefik.http.routers.otel-http.rule"
    value = "Host(`otel-http.${var.cert_domain}`)"
  }
  labels {
    label = "traefik.http.routers.otel-http.middlewares"
    value = "otel-auth@file"
  }
  labels {
    label = "traefik.http.routers.otel-http.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.routers.otel-http.service"
    value = "otel-http"
  }
  labels {
    label = "traefik.http.routers.otel-http.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.otel-http.tls.certresolver"
    value = "duckdns"
  }
  labels {
    label = "traefik.http.routers.otel-http.tls.domains[0].main"
    value = var.cert_domain
  }
  labels {
    label = "traefik.http.routers.otel-http.tls.domains[0].sans"
    value = "*.${var.cert_domain}"
  }
  labels {
    label = "traefik.http.services.otel-http.loadbalancer.server.port"
    value = "4318"
  }
  labels {
    label = "traefik.http.services.otel-http.loadbalancer.server.scheme"
    value = "http"
  }

}
