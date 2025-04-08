terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    # cloudflare = {
    #   source  = "cloudflare/cloudflare"
    #   version = "~> 5.2"
    # }
  }
}

provider "docker" {
  alias = "local"
}

provider "docker" {
  alias = "rpi"
  host  = "tcp://${var.pi_ip_address}:2375"
}
