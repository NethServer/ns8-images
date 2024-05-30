source "qemu" "dn" {
  iso_url      = "https://cloud.debian.org/images/cloud/bookworm/20230802-1460/debian-12-generic-amd64-20230802-1460.qcow2"
  iso_checksum = "file:https://cloud.debian.org/images/cloud/bookworm/20230802-1460/SHA512SUMS"
  disk_image   = true
  headless     = true
  qemuargs = [
    ["-smbios", "type=1,serial=ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/"]
  ]
  http_content         = local.cloud-init
  ssh_username         = "debian"
  ssh_private_key_file = data.sshkey.install.private_key_path
  shutdown_command     = "sudo shutdown -P now"
  disk_compression     = true
  output_directory     = "qemu_ns8_dn"
  vm_name              = "ns8-debian-12-${var.core_version}.qcow2"
}

source "qemu" "rl" {
  iso_url      = "https://dl.rockylinux.org/pub/rocky/9.4/images/x86_64/Rocky-9-GenericCloud-Base-9.4-20240523.0.x86_64.qcow2"
  iso_checksum = "sha256:39277948d53a10f1087454a1e0ed1c9bb48b48f6a4ddbf5113adc36f70be6730"
  disk_image   = true
  headless     = true
  cpu_model    = "host"
  qemuargs = [
    ["-smbios", "type=1,serial=ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/"],
    ["-boot",  "menu=on,splash-time=5000"]
  ]
  http_content         = local.cloud-init
  ssh_username         = "rocky"
  ssh_private_key_file = data.sshkey.install.private_key_path
  shutdown_command     = "sudo shutdown -P now"
  disk_compression     = true
  output_directory     = "qemu_ns8_rl"
  vm_name              = "ns8-rocky-linux-9-${var.core_version}.qcow2"
  boot_wait            = "4s"
  boot_command = [
    "c<wait>",
    "load_video",
    "<enter><wait>",
    "set gfxpayload=keep",
    "<enter><wait>",
    "insmod gzio",
    "<enter><wait>",
    "linux ($root)/vmlinuz-5.14.0-427.16.1.el9_4.x86_64 console=ttyS0,115200n8 no_timer_check crashkernel=auto net.ifnames=0 root=LABEL=rocky ds=nocloud-net';'s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<enter><wait>",
    "initrd ($root)/initramfs-5.14.0-427.16.1.el9_4.x86_64.img",
    "<enter><wait>",
    "boot",
    "<enter><wait>"
  ]
}
