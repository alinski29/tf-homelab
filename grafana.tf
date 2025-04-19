resource "docker_image" "grafana" {
  name          = data.docker_registry_image.grafana.name
  provider      = docker.rpi
  platform      = "arm64"
  force_remove  = true
  pull_triggers = [data.docker_registry_image.grafana.sha256_digest]
}

resource "null_resource" "grafana_config" {
  triggers = {
    template_file = filesha256("${path.module}/files/grafana/grafana-datasources.yaml.tpl")
  }

  connection {
    type        = "ssh"
    user        = "pi"
    host        = var.pi_ip_address
    private_key = file("${var.local_home}/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.pi_docker_volumes_home}/grafana/conf/provisioning/datasources"
    ]
  }

  provisioner "file" {
    content = templatefile("${path.module}/files/grafana/grafana-datasources.yaml.tpl", {
      prometheus_url = "http://prometheus:9090"
      loki_url       = ""
      tempo_url      = ""
      pyroscope_url  = ""
    })
    destination = "${local.pi_docker_volumes_home}/grafana/conf/provisioning/datasources/grafana-datasources.yaml"
  }
}

resource "null_resource" "grafana_dashboards_setup" {
  connection {
    type        = "ssh"
    user        = "pi"
    host        = var.pi_ip_address
    private_key = file("${var.local_home}/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.pi_docker_volumes_home}/grafana/conf/provisioning/dashboards"
    ]
  }
}

resource "null_resource" "grafana_dashboards" {
  for_each = fileset("${path.module}/files/grafana", "*.json")

  depends_on = [null_resource.grafana_dashboards_setup]

  triggers = {
    template_file = filesha256("${path.module}/files/grafana/${each.value}")
  }

  connection {
    type        = "ssh"
    user        = "pi"
    host        = var.pi_ip_address
    private_key = file("${var.local_home}/.ssh/id_rsa")
  }

  provisioner "file" {
    source      = "${path.module}/files/grafana/${each.value}"
    destination = "${local.pi_docker_volumes_home}/grafana/conf/provisioning/dashboards/${each.value}"
  }
}

resource "docker_container" "grafana" {
  provider     = docker.rpi
  name         = "grafana"
  image        = docker_image.grafana.image_id
  hostname     = "grafana"
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.homelab.name
  }
  restart = "unless-stopped"

  env = [
    "GF_LOG_LEVEL=info",
    "GF_PLUGINS_PREINSTALL=grafana-clock-panel, grafana-simple-json-datasource, grafana-lokiexplore-app",
    "GF_AUTH_ANONYMOUS_ENABLED=false",
    "GF_AUTH_ANONYMOUS_ORG_ROLE=Admin",
    "GF_SECURITY_ADMIN_USER=admin",
    "GF_SECURITY_ADMIN_PASSWORD=${var.grafana_admin_password}",
  ]

  healthcheck {
    test         = ["CMD-SHELL", "curl --silent --fail http://grafana.${var.cert_domain}/api/health || exit 1"]
    interval     = "30s"
    timeout      = "10s"
    retries      = 3
    start_period = "15s"
  }

  volumes {
    host_path      = "${local.pi_docker_volumes_home}/grafana"
    container_path = "/var/lib/grafana"
  }
  volumes {
    host_path      = "${local.pi_docker_volumes_home}/grafana/conf/provisioning"
    container_path = "/etc/grafana/provisioning"
  }

  log_opts = {
    tag = "{{.Name}}|{{.ID}}"
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.grafana.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.grafana.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.routers.grafana.tls.certresolver"
    value = "duckdns"
  }
  labels {
    label = "traefik.http.routers.grafana.tls.domains[0].main"
    value = var.cert_domain
  }
  labels {
    label = "traefik.http.routers.grafana.tls.domains[0].sans"
    value = "*.${var.cert_domain}"
  }
  labels {
    label = "traefik.http.routers.grafana.rule"
    value = "Host(`grafana.${var.cert_domain}`)"
  }
  labels {
    label = "traefik.http.services.grafana.loadbalancer.server.port"
    value = "3000"
  }

}
