resource "docker_image" "prometheus" {
  name          = data.docker_registry_image.prometheus.name
  provider      = docker.rpi
  platform      = "arm64"
  force_remove  = true
  pull_triggers = [data.docker_registry_image.prometheus.sha256_digest]
}

resource "null_resource" "prometheus_config" {
  triggers = {
    template_file = filesha256("${path.module}/files/prometheus/prometheus.yaml")
  }

  connection {
    type        = "ssh"
    user        = "pi"
    host        = var.pi_ip_address
    private_key = file("${var.local_home}/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.pi_docker_volumes_home}/prometheus"
    ]
  }

  provisioner "file" {
    content     = file("${path.module}/files/prometheus/prometheus.yaml")
    destination = "${local.pi_docker_volumes_home}/prometheus/prometheus.yml"
  }
}

resource "docker_container" "prometheus" {
  provider     = docker.rpi
  name         = "prometheus"
  image        = docker_image.prometheus.image_id
  hostname     = "prometheus"
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.homelab.name
  }
  restart = "unless-stopped"

  command = [
    "--web.enable-remote-write-receiver",
    "--web.enable-otlp-receiver",
    "--enable-feature=exemplar-storage",
    "--enable-feature=native-histograms"
  ]

  volumes {
    host_path      = "${local.pi_docker_volumes_home}/prometheus"
    container_path = "/prometheus"
  }

  log_opts = {
    tag = "{{.Name}}|{{.ID}}"
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.prometheus.middlewares"
    value = "prometheus-auth@file"
  }
  labels {
    label = "traefik.http.routers.prometheus.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.prometheus.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.routers.prometheus.tls.certresolver"
    value = "duckdns"
  }
  labels {
    label = "traefik.http.routers.prometheus.tls.domains[0].main"
    value = var.cert_domain
  }
  labels {
    label = "traefik.http.routers.prometheus.tls.domains[0].sans"
    value = "*.${var.cert_domain}"
  }
  labels {
    label = "traefik.http.routers.prometheus.rule"
    value = "Host(`prometheus.${var.cert_domain}`)"
  }
  labels {
    label = "traefik.http.services.prometheus.loadbalancer.server.port"
    value = "9090"
  }

}
