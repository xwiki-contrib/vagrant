variable "debian_iso_url" {
  type    = string
  default = "http://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.1.0-amd64-netinst.iso"
}

variable "debian_iso_checksum" {
  type    = string
  default = "sha512:02257c3ec27e45d9f022c181a69b59da67e5c72871cdb4f9a69db323a1fad58093f2e69702d29aa98f5f65e920e0b970d816475a5a936e1f3bf33832257b7e92"
}

variable "vagrant_cloud_access_token" {
  type    = string
}

variable "xwiki_dist" {
  type    = string
  default = "stable"
}

variable "xwiki_version" {
  type    = string
}

variable "xwiki_tomcat" {
  type    = string
  default = "tomcat9"
}

variable "xwiki_db" {
  type    = string
  default = "mariadb"
}

source "qemu" "qemu" {
  accelerator       = "kvm"
  boot_command      = ["<esc><wait1s>", "auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg", "<enter>"]
  boot_wait         = "10s"
  disk_interface    = "virtio-scsi"
  disk_size         = "5000M"
  format            = "qcow2"
  http_directory    = "debian-preseed"
  iso_checksum      = var.debian_iso_checksum
  iso_url           = var.debian_iso_url
  vm_name           = "xwiki_qemu"
  output_directory  = "output-qemu"
  memory            = 1024
  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
  ssh_username      = "vagrant"
  ssh_password      = "vagrant"
  ssh_timeout       = "20m"
}

source "virtualbox-iso" "vbox" {
  boot_command      = ["<esc><wait1s>", "auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg", "<enter>"]
  guest_os_type     = "Debian_64"
  http_directory    = "debian-preseed"
  iso_checksum      = var.debian_iso_checksum
  iso_url           = var.debian_iso_url
  memory            = 1024
  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
  ssh_password      = "vagrant"
  ssh_username      = "vagrant"
  ssh_timeout       = "20m"
}

build {
  sources = ["source.virtualbox-iso.vbox", "source.qemu.qemu"]

  provisioner "shell" {
    inline = [
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg",
      "wget -q \"https://maven.xwiki.org/public.gpg\" -O- | sudo apt-key add -",
      "sudo wget \"https://maven.xwiki.org/${var.xwiki_dist}/xwiki-${var.xwiki_dist}.list\" -P /etc/apt/sources.list.d/",
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y xwiki-${var.xwiki_tomcat}-${var.xwiki_db}",
      "sudo sed -i '/JAVA_OPTS/s/\"$/ -Xms1024m -Xmx1024m\"/' /etc/default/${var.xwiki_tomcat}"
    ]
  }

  post-processors {
    post-processor "vagrant" {
      compression_level = 9
      output = "packer_{{.Provider}}.box"
      vagrantfile_template = "Vagrantfile"
    }

    post-processor "vagrant-cloud" {
      box_tag = "xwiki/${var.xwiki_dist}-${var.xwiki_tomcat}-${var.xwiki_db}"
      version = "${var.xwiki_version}"
      access_token = "${var.vagrant_cloud_access_token}"
    }
  }
}
