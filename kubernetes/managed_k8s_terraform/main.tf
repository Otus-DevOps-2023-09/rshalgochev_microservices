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
 resource "yandex_iam_service_account" "my_k8s_cluster" {
   name = "my-k8s-cluster"
   description = "service account for my_k8s_cluster"
 }

resource "yandex_resourcemanager_folder_iam_binding" "admin" {
  folder_id = var.folder_id
  members   = ["serviceAccount:${yandex_iam_service_account.my_k8s_cluster.id}"]
  role      = "editor"
  depends_on = [yandex_iam_service_account.my_k8s_cluster]
}

resource "yandex_vpc_network" "k8s" {
  name = "k8s"
}

resource "yandex_vpc_subnet" "k8s-subnet-a" {
  network_id     = yandex_vpc_network.k8s.id
  v4_cidr_blocks = ["10.0.0.0/16"]
  name = "k8s-subnet-a"
  zone = var.zone
}

resource "yandex_kubernetes_cluster" "my_k8s_cluster" {
  network_id              = yandex_vpc_network.k8s.id
  node_service_account_id = yandex_iam_service_account.my_k8s_cluster.id
  service_account_id      = yandex_iam_service_account.my_k8s_cluster.id
  release_channel = "RAPID"
  network_policy_provider = "CALICO"
  master {
    version = "1.26"
    zonal {
      zone = var.zone
      subnet_id = yandex_vpc_subnet.k8s-subnet-a.id
    }
    public_ip = true

    maintenance_policy {
      auto_upgrade = true
      maintenance_window {
        duration   = "5h"
        start_time = "02:00"
      }
    }
  }
  depends_on = [yandex_iam_service_account.my_k8s_cluster, yandex_resourcemanager_folder_iam_binding.admin]
}

resource "yandex_kubernetes_node_group" "k8s_node_group" {
  cluster_id = yandex_kubernetes_cluster.my_k8s_cluster.id
  name = "k8s-node-group"
  version = "1.26"
  instance_template {
    platform_id = "standard-v2"
    network_interface {
      nat = true
      subnet_ids = [yandex_vpc_subnet.k8s-subnet-a.id]
    }
    resources {
      memory = 8
      cores = 4
    }
    boot_disk {
      type = "network-hdd"
      size = 64
    }
    metadata = {
      ssh-keys = "ubuntu:${file(var.public_key)}"
    }
    scheduling_policy {
      preemptible = false
    }
  }
  scale_policy {
    fixed_scale {
      size = 2
    }
  }
  allocation_policy {
    location {
      zone = var.zone
    }
  }
  maintenance_policy {
    auto_repair  = true
    auto_upgrade = true
    maintenance_window {
      day = "sunday"
      duration   = "5h"
      start_time = "02:00"
    }
  }
  depends_on = [
  yandex_iam_service_account.my_k8s_cluster,
  yandex_resourcemanager_folder_iam_binding.admin
  ]
}
