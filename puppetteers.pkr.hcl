# os-install.pkr.hcl
packer {
  required_version = "= 1.11.2"
  required_plugins {
    qemu = {
      version = "= 1.1.0"
      source = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "iso" {
  vm_name              = "ubuntu-2404-amd64.raw"
  iso_url              = "https://cdimage.ubuntu.com/releases/24.04/release/ubuntu-24.04.1-live-server-arm64.iso"
  iso_checksum         = "5ceecb7ef5f976e8ab3fffee7871518c8e9927ec221a3bb548ee1193989e1773"
  memory               = 4000
  disk_image           = false
  output_directory     = "build/os-base"
  qemu_binary         = "qemu-system-aarch64"
  accelerator          = "kvm"
  disk_size            = "12000M"
  disk_interface       = "virtio"
  format               = "raw"
  net_device           = "virtio-net"
  boot_wait            = "3s"
  boot_command         = [
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=\"nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/\" ",
    "<f10>"
    ]
  http_directory       = "http"
  shutdown_command     = "echo 'packer' | sudo -S shutdown -P now"
  ssh_username         = "packer"
  ssh_password         = "packer"
  ssh_timeout          = "60m"
  qemuargs = [
    ["-machine", "virt"],     # Machine type for QEMU, raspi3 has problem Cannot use read-only drive as SD card
    ["-smp", "4"],
    ["-m", "4000"],
    ["-device", "virtio-gpu-pci"],
    [ "-boot", "strict=off" ]
  ]
}

build {
  name    = "iso"
  sources = ["source.qemu.iso"]
}