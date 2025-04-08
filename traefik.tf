resource "docker_network" "homelab" {
  provider = docker.rpi
  name     = "homelab"
  driver   = "bridge"
}

resource "docker_image" "traefik" {
  provider      = docker.rpi
  name          = data.docker_registry_image.traefik.name
  force_remove  = true
  pull_triggers = [data.docker_registry_image.traefik.sha256_digest]
}

# Resource to manage the Traefik configuration file upload
resource "null_resource" "traefik_config_upload" {
  triggers = {
    template_file = filesha256("${path.module}/files/traefik-config.yml.tpl")
  }

  connection {
    type        = "ssh"
    user        = "pi"
    host        = var.pi_ip_address
    private_key = file("${var.local_home}/.ssh/id_rsa")
  }

  provisioner "file" {
    content = templatefile("${path.module}/files/traefik-config.yml.tpl", {
      # cloudflare_email = var.cloudflare_email
      cert_domain   = var.cert_domain
      pi_ip_address = var.pi_ip_address
    })
    destination = "${var.pi_home}/.config/traefik.yml"
  }
}

resource "docker_container" "traefik" {
  depends_on = [
    null_resource.traefik_config_upload
  ]
  provider     = docker.rpi
  name         = "traefik"
  image        = docker_image.traefik.image_id
  restart      = "unless-stopped"
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.homelab.name
  }

  env = [
    # "CF_DNS_API_TOKEN=${var.cloudflare_api_token}",
    "DUCKDNS_TOKEN=${var.duckdns_api_token}",
    "DUCKDNS_PROPAGATION_TIMEOUT=180",
    "DUCKDNS_POLLING_INTERVAL=5"
  ]

  ports {
    internal = 80
    external = 80
  }
  ports {
    internal = 443
    external = 443
  }
  # Optional: Expose Traefik dashboard (secured)
  ports {
    internal = 8080
    external = 8090
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }
  volumes {
    host_path      = "${var.pi_home}/.config/traefik.yml"
    container_path = "/etc/traefik/traefik.yaml"
  }
  volumes {
    host_path      = "${local.pi_docker_volumes_home}/traefik/conf/"
    container_path = "/etc/traefik/conf/"
    read_only      = true
  }
  volumes {
    host_path      = "${local.pi_docker_volumes_home}/traefik/certs/"
    container_path = "/etc/traefik/certs/"
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.traefik.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.traefik.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.routers.traefik.tls.certresolver"
    value = "duckdns"
  }
  labels {
    label = "traefik.http.routers.traefik.tls.domains[0].main"
    value = var.cert_domain
  }
  labels {
    label = "traefik.http.routers.traefik.tls.domains[0].sans"
    value = "*.${var.cert_domain}"
  }
  labels {
    label = "traefik.http.routers.traefik.rule"
    value = "Host(`traefik.${var.cert_domain}`)"
  }
  labels {
    label = "traefik.http.services.traefik.loadbalancer.server.port"
    value = "8080"
  }
}
