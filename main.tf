terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "shuup_net" {
  name = "shuup-network"
}

resource "null_resource" "shuup_deploy" {
    provisioner "local-exec" {
    command     = "docker-compose up -d"
    working_dir = "/mnt/c/sre/shuup"
    }


  depends_on = [docker_network.shuup_net]
}

output "shuup_url" {
  value = "http://localhost:8000"
}

output "grafana_url" {
  value = "http://localhost:3000"
}
