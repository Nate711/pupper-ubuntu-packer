packer {
  required_version = "= 1.11.2"
  required_plugins {
    qemu = {
      version = "= 1.1.0"
      source = "github.com/hashicorp/qemu"
    }
  }
}

variable "password" {
  type    = string
  default = "ubuntu"
}

source "qemu" "iso" {
  vm_name              = "ubuntu-2404-arm64.raw"
  iso_url              = "https://cdimage.ubuntu.com/releases/24.04/release/ubuntu-24.04.1-live-server-arm64.iso"
  iso_checksum         = "5ceecb7ef5f976e8ab3fffee7871518c8e9927ec221a3bb548ee1193989e1773"
  
  qemu_binary         = "qemu-system-aarch64"
  format              = "qcow2"
  output_directory    = "output"
  shutdown_command    = "echo '${var.password}' | sudo -S shutdown -P now"

  accelerator         = "kvm"
  cpus                = 4
  memory              = 4096
#   use_default_display = true
  # To not run Qemu window. For Debuging set the value to `false`
  headless            = false

  http_directory = "http"
  ssh_username   = "ubuntu"
  ssh_password   = var.password
  ssh_timeout    = "20m"
  ssh_port = 2222

  boot_wait = "10s"
  boot_command = [
    "c<wait>linux /casper/vmlinuz --- autoinstall 'ds=nocloud;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'<enter><wait>",
    "initrd /casper/initrd<enter><wait><wait>",
    "boot<enter><wait>"
  ]
  qemuargs = [
    ["-machine", "virt"],     # Machine type for QEMU
    ["-boot", "strict=off"],
    ["-netdev", "user,id=user.0,hostfwd=tcp::2222-:22"],  # Port forwarding    
    ["-device", "virtio-net,netdev=user.0"]
  ]
}

build {
  name    = "iso"
  sources = ["source.qemu.iso"]
}