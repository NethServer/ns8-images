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
  iso_url      = "https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base-9.3-20231113.0.x86_64.qcow2"
  iso_checksum = "sha256:7713278c37f29b0341b0a841ca3ec5c3724df86b4d97e7ee4a2a85def9b2e651"
  disk_image   = true
  headless     = true
  cpu_model    = "host"
  qemuargs = [
    ["-smbios", "type=1,serial=ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/"]
  ]
  http_content         = local.cloud-init
  ssh_username         = "rocky"
  ssh_private_key_file = data.sshkey.install.private_key_path
  shutdown_command     = "sudo shutdown -P now"
  disk_compression     = true
  output_directory     = "qemu_ns8_rl"
  vm_name              = "ns8-rocky-linux-9-${var.core_version}.qcow2"
}
