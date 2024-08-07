build {

  sources = [
    "source.digitalocean.rl",
    "source.qemu.dn",
    "source.qemu.rl",
  ]

  provisioner "shell" {
    inline = [
      "systemctl is-system-running --wait || true",
    ]
  }


  provisioner "shell" {
    only = ["qemu.rl"]
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    inline = [
      "dnf remove -y cockpit-system cockpit-bridge cockpit-ws",
      "dnf install -y 'dnf-command(versionlock)'",
      "dnf versionlock add cloud-init",
    ]
  }

  provisioner "shell" {
    env = {
      "NS8_TWO_STEPS_INSTALL" : "1"
    }
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    expect_disconnect = true
    inline = [
      "curl https://raw.githubusercontent.com/NethServer/ns8-core/ns8-stable/core/install.sh > install.sh",
      "chmod +x install.sh",
      "./install.sh ${local.core_module}",
    ]
  }

  provisioner "file" {
    content     = <<-EOT
    [Unit]
    Wants=network-online.target
    After=network-online.target
    ConditionFirstBoot=yes
    ConditionPathExists=!/var/lib/nethserver/node/ready
    [Service]
    Type=oneshot
    ExecStart=/bin/bash /var/lib/nethserver/node/install-finalize.sh
    ExecStartPost=/usr/bin/touch /var/lib/nethserver/node/ready
    RemainAfterExit=yes
    [Install]
    WantedBy=multi-user.target
    EOT
    destination = "/tmp/ns8-install-finalize.service"
  }

  provisioner "shell" {
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    inline = ["mv /tmp/ns8-install-finalize.service /etc/systemd/system/"]
  }

  provisioner "shell" {
    except = ["qemu.dn"]
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    inline = [ "/sbin/restorecon -v /etc/systemd/system/ns8-install-finalize.service"]
  }

  provisioner "shell" {
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    inline = [
      "systemctl daemon-reload",
      "systemctl enable ns8-install-finalize.service",
    ]
  }

  provisioner "shell" {
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    inline = [
      "rm install.sh",
      "cloud-init clean --logs --seed",
      "rm -rvf /etc/ssh/sshd_config.d/50-cloud-init.conf",
      "echo uninitialized > /etc/machine-id",
    ]
  }

  provisioner "shell" {
    only = ["qemu.rl"]
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    inline = [
      "dnf versionlock delete cloud-init",
      "dnf remove -y 'dnf-command(versionlock)'",
      "dnf clean all",
      "rm -rf /var/lib/dnf/repos/* /var/cache/dnf/*",
    ]
  }

  provisioner "shell" {
    only = ["qemu.dn"]
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    inline = ["rm -f /etc/netplan/*"]
  }

  provisioner "file" {
    only = ["qemu.dn"]
    content     = <<-EOT
network:
    version: 2
    ethernets:
        all-en:
            match:
                name: en*
            dhcp4: true
            dhcp4-overrides:
                use-domains: true
            dhcp6: true
            dhcp6-overrides:
                use-domains: true
        all-eth:
            match:
                name: eth*
            dhcp4: true
            dhcp4-overrides:
                use-domains: true
            dhcp6: true
            dhcp6-overrides:
                use-domains: true
EOT
destination = "/tmp/ns8-netplan-debian"
  }

  provisioner "shell" {
    only = ["qemu.dn"]
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    inline = ["mv /tmp/ns8-netplan-debian /etc/netplan/50-cloud-init.yaml"]
  }

  provisioner "shell" {
    only = ["qemu.dn"]
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    inline = [
      "netplan generate",
      "netplan apply",
    ]
  }

  provisioner "shell" {
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    inline = [
      "dd if=/dev/zero of=/swapfile bs=1M count=4096",
      "chmod 600 /swapfile",
      "mkswap /swapfile",
      "echo /swapfile   swap    swap    defaults    0 0 >> /etc/fstab"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo rm -rf /root/.ssh /home/debian/.ssh /home/rocky/.ssh || true",
    ]
  }


  post-processor "manifest" {}
}
