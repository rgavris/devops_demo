terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "server" {
  image     = "ubuntu-22-04-x64"
  name      = "my-server"
  region    = "nyc1"
  size      = "s-1vcpu-1gb"
  ssh_keys  = [data.digitalocean_ssh_key.selected.id]
  user_data = <<-EOF
    #cloud-config
    package_update: false
    package_upgrade: false
  EOF
}

data "digitalocean_ssh_key" "selected" {
  name        = "My key"
}

output "server_ip" {
  value = digitalocean_droplet.server.ipv4_address
}

