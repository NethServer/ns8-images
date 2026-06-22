source "qemu" "rl" {
  iso_url      = "https://dl.rockylinux.org/pub/rocky/9.8/images/x86_64/Rocky-9-GenericCloud-Base-9.8-20260525.0.x86_64.qcow2"
  iso_checksum = "sha256:92c206cc6f790c61583247eefe87890f8828420662c17cacf247cec78ab4eec8"
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
  vm_name              = "ns8-rocky-linux-9-ns8-stable.qcow2"
}
