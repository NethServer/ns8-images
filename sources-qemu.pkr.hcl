source "qemu" "dn" {
  iso_url      = "https://cloud.debian.org/images/cloud/bookworm/20230612-1409/debian-12-generic-amd64-20230612-1409.qcow2"
  iso_checksum = "file:https://cloud.debian.org/images/cloud/bookworm/20230612-1409/SHA512SUMS"
  disk_image   = true
  headless     = true
  disk_size    = "10G"
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
  iso_url      = "https://dl.rockylinux.org/vault/rocky/9.1/images/x86_64/Rocky-9-GenericCloud-Base-9.1-20230215.0.x86_64.qcow2"
  iso_checksum = "file:https://dl.rockylinux.org/vault/rocky/9.1/images/x86_64/Rocky-9-GenericCloud-Base-9.1-20230215.0.x86_64.qcow2.CHECKSUM"
  disk_image   = true
  headless     = true
  cpu_model    = "host"
  disk_size    = "10G"
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

source "qemu" "cs" {
  iso_url      = "https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-20230327.0.x86_64.qcow2"
  iso_checksum = "file:https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-20230327.0.x86_64.qcow2.SHA256SUM"
  disk_image   = true
  headless     = true
  cpu_model    = "host"
  disk_size    = "10G"
  qemuargs = [
    ["-smbios", "type=1,serial=ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/"]
  ]
  http_content         = local.cloud-init
  ssh_username         = "cloud-user"
  ssh_private_key_file = data.sshkey.install.private_key_path
  shutdown_command     = "sudo shutdown -P now"
  disk_compression     = true
  output_directory     = "qemu_ns8_cs"
  vm_name              = "ns8-centos-stream-9-${var.core_version}.qcow2"
}

source "qemu" "al" {
  iso_url      = "https://repo.almalinux.org/almalinux/9.1/cloud/x86_64/images/AlmaLinux-9-GenericCloud-9.1-20221118.x86_64.qcow2"
  iso_checksum = "1e93210a0c534de76ae01dc02e8224be14264fa8d54ad6cff9af15b673c6db1a"
  disk_image   = true
  headless     = true
  cpu_model    = "host"
  disk_size    = "10G"
  qemuargs = [
    ["-smbios", "type=1,serial=ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/"]
  ]
  http_content         = local.cloud-init
  ssh_username         = "almalinux"
  ssh_private_key_file = data.sshkey.install.private_key_path
  shutdown_command     = "sudo shutdown -P now"
  disk_compression     = true
  output_directory     = "qemu_ns8_al"
  vm_name              = "ns8-alma-linux-9-${var.core_version}.qcow2"
}
