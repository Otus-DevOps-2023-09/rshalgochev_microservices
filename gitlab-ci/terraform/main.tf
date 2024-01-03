terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~>0.35"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = pathexpand(var.service_account_key)
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

resource "yandex_compute_instance" "gitlab-server" {
  name = "gitlab"
  zone = var.zone
  boot_disk {
    initialize_params {
      image_id = var.image_id
      size = 50
    }
  }
  network_interface {
    subnet_id = var.subnet_id
    nat = true
  }
  resources {
    cores  = 2
    memory = 4
    core_fraction = 5
  }
  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key)}"
  }
  scheduling_policy {
    preemptible = true
  }
}

locals {
  names = [yandex_compute_instance.gitlab-server.name]
  ips = [yandex_compute_instance.gitlab-server.network_interface.0.nat_ip_address]
}

resource "local_file" "template_inventory" {
  filename = "inventory"
  content = templatefile("inventory.tpl", {
  names = local.names
  ips = local.ips
  }
  )
  provisioner "local-exec" {
    command = "chmod a-x inventory"
  }
  provisioner "local-exec" {
    command = "cp inventory ../ansible/inventory"
  }
  provisioner "local-exec" {
    command = "mv inventory inventory.back"
    when = destroy
    on_failure = continue
  }
  provisioner "local-exec" {
    working_dir = "../ansible"
    command = "ansible-playbook start-gitlab.yml"
  }
}
