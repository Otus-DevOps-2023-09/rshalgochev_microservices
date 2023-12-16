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

resource "yandex_compute_instance" "docker-host" {
  count = var.app_count
  name = "docker-app-${count.index}"
  zone = var.zone
  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }
  network_interface {
    subnet_id = var.subnet_id
    nat = true
  }
  resources {
    cores  = 2
    memory = 2
    core_fraction = 5
  }
  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
}
locals {
  names = yandex_compute_instance.docker-host[*].name
  ips = yandex_compute_instance.docker-host[*].network_interface.0.nat_ip_address
}

resource "local_file" "ansible_inventory_generator" {
  content = templatefile("inventory.tpl", {
    names = local.names,
    ips   = local.ips,
  })
  filename = "inventory"

  provisioner "local-exec" {
    command = "chmod a-x inventory && cp -u invenroty ../ansible/inventory"
  }

  provisioner "local-exec" {
    command = "mv inventory inventory.back"
    when = destroy
    on_failure = continue
  }
  provisioner "local-exec" {
    command = "ansible-playbook run_docker_app.yml"
    working_dir = "../ansible"
  }
}
