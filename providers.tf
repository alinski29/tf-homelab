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
  }
}

provider "docker" {
  alias = "local"
}

provider "docker" {
  alias = "rpi"
  host  = "tcp://192.168.0.250:2375"
}
