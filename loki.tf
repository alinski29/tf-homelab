// filepath: /home/alinski/Dev/Personal/tf-homelab/loki.tf
resource "docker_image" "loki" {
  name          = "grafana/loki"
  provider      = docker.rpi
  platform      = "arm64"
  force_remove  = true
  pull_triggers = [] # No registry image defined yet
}

resource "null_resource" "loki_config" {
  triggers = {
    template_file = filesha256("${path.module}/files/loki/loki-config.yaml.tpl")
  }

  connection {
    type        = "ssh"
    user        = "pi"
    host        = var.pi_ip_address
    private_key = file("${var.local_home}/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.pi_docker_volumes_home}/loki"
    ]
  }

  provisioner "file" {
    content     = templatefile("${path.module}/files/loki/loki-config.yaml.tpl", {})
    destination = "${local.pi_docker_volumes_home}/loki/loki-config.yaml"
  }
}

resource "docker_container" "loki" {
  provider     = docker.rpi
  name         = "loki"
  image        = docker_image.loki.image_id
  hostname     = "loki"
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.homelab.name
  }
  restart = "unless-stopped"

  command = [
    "-config.file=/etc/loki/config.yaml"
  ]

  volumes {
    host_path      = "${local.pi_docker_volumes_home}/loki/loki-config.yaml"
    container_path = "/etc/loki/config.yaml"
  }
  volumes {
    host_path      = "${local.pi_docker_volumes_home}/loki/data"
    container_path = "/data/loki"
  }

  log_opts = {
    tag = "{{.Name}}|{{.ID}}"
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.loki.middlewares"
    value = "loki-auth@file"
  }
  labels {
    label = "traefik.http.routers.loki.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.loki.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.routers.loki.tls.certresolver"
    value = "duckdns"
  }
  labels {
    label = "traefik.http.routers.loki.tls.domains[0].main"
    value = var.cert_domain
  }
  labels {
    label = "traefik.http.routers.loki.tls.domains[0].sans"
    value = "*.${var.cert_domain}"
  }
  labels {
    label = "traefik.http.routers.loki.rule"
    value = "Host(`loki.${var.cert_domain}`)"
  }
  labels {
    label = "traefik.http.services.loki.loadbalancer.server.port"
    value = "3100"
  }
}
