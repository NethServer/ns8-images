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
      "dnf config-manager -v --save --setopt=exclude='kernel* kmod* microcode_ctl grub2*'",
    ]
  }

  provisioner "shell" {
    env = {
      "NS8_TWO_STEPS_INSTALL" : "1"
    }
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    expect_disconnect = true
    inline = [
      "curl https://raw.githubusercontent.com/NethServer/ns8-core/ns8-stable/core/install.sh | bash -s ${local.core_module}",
    ]
  }

  provisioner "file" {
    content     = <<-EOT
    [Unit]
    Wants=network-online.target
    After=network-online.target
    [Service]
    Type=oneshot
    ExecStart=-/bin/bash /etc/randompassword
    ExecStart=/bin/bash /var/lib/nethserver/node/install-finalize.sh
    ExecStart=/usr/bin/systemctl disable ns8-install-finalize.service
    ExecStart=/usr/bin/rm -f /etc/systemd/system/ns8-install-finalize.service
    ExecStart=/usr/bin/systemctl daemon-reload
    RemainAfterExit=no
    [Install]
    WantedBy=multi-user.target
    EOT
    destination = "/tmp/ns8-install-finalize.service"
  }

  provisioner "file" {
    only = ["qemu.rl"]
    content     = <<-EOT
    #!/bin/bash
    if [ -f /etc/passwordset ]; then
      exit 0
    fi
    PASSWORD=$(tr -dc A-Xa-x0-9\!, < /dev/urandom | head -c 12 | xargs)
    echo $PASSWORD | passwd --stdin root
    echo -e "Generated root password:\n$PASSWORD\n" > /etc/issue.d/password.issue
    passwd -e root
    touch /etc/passwordset
    EOT
    destination = "/tmp/randompassword"
  }

  provisioner "shell" {
    only = ["qemu.rl"]
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    inline = [
      "mv /tmp/randompassword /etc/",
      "chmod +x /etc/randompassword",
      "echo -e \"if [ -f /etc/issue.d/password.issue ]; then\n  rm -f /etc/issue.d/password.issue /etc/passwordset /etc/randompassword\nfi\" >> /root/.bash_profile",
    ]
  }

  provisioner "shell" {
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    inline = [
      "install /tmp/ns8-install-finalize.service /etc/systemd/system/",
      "systemctl daemon-reload",
      "systemctl enable ns8-install-finalize.service",
    ]
  }

  provisioner "shell" {
    only = ["qemu.rl"]
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    inline = [
      "dnf config-manager -v --save --setopt=exclude=",
      "dnf clean -v all",
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
      "echo /swapfile   swap    swap    defaults    0 0 >> /etc/fstab",
      "cloud-init clean -c all --logs --seed --machine-id",
      "rm -rvf /root/.ssh /home/rocky/.ssh /home/debian/.ssh",
      "passwd -l rocky || :"
    ]
  }

  post-processor "manifest" {}
}
