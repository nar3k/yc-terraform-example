provider "yandex" {
  token     = "${var.token}"
  cloud_id  = "${var.cloud_id}"
  folder_id = "${var.folder_id}"
}

data "yandex_compute_image" "base_image" {
  family = "${var.yc_image_family}"
}

resource "yandex_compute_instance" "node" {
  count       = "${var.cluster_size}"
  name        = "nlb-node-${count.index}"
  hostname    = "nlb-node-${count.index}"
  description = "nlb-node-${count.index} of my cluster"
  zone = "${element(var.zones, count.index)}"

  resources {
    cores  = "${var.instance_cores}"
    memory = "${var.instance_memory}"
  }

  boot_disk {
    initialize_params {
      image_id = "${data.yandex_compute_image.base_image.id}"
      type_id = "network-nvme"
      size = "31"
    }
  }


  network_interface {
    subnet_id = "${element(local.subnet_ids, count.index)}"
    nat       = true
  }

  metadata {
    ssh-keys  = "centos:${file("${var.public_key_path}")}"
    user-data = "${data.template_file.cloud-init.rendered}"
  }

  labels {
    node_id      = "${count.index}"
  }
}

locals {
  external_ips = ["${yandex_compute_instance.node.*.network_interface.0.nat_ip_address}"]
}
