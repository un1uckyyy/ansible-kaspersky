terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "alma" {
  name = "alma"
  type = "dir"
  target {
    path = "/var/lib/libvirt/images/alma"
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.cfg")
}

resource "libvirt_volume" "almalinux-qcow2" {
  name   = "almalinux.qcow2"
  pool   = libvirt_pool.alma.name
  source = "${path.module}/alma/AlmaLinux-9-GenericCloud-9.5-20241120.x86_64.qcow2"
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  pool           = libvirt_pool.alma.name
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
}


resource "libvirt_network" "public_network" {
  name   = "alma_network"
  mode   = "nat"
  domain = "alma.local"
  addresses = ["10.10.10.10/24"]
  dhcp {
    enabled = true
  }
  dns {
    enabled = true
  }
}

resource "libvirt_domain" "domain-alma" {
  name   = "alma9-terraform"
  memory = "2048"
  vcpu   = 2

  cpu {
    mode = "host-passthrough"
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_id   = libvirt_network.public_network.id
    network_name = libvirt_network.public_network.name
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.almalinux-qcow2.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
