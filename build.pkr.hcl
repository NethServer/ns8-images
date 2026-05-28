build {

  sources = [
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
    ExecStart=/bin/bash -c 'if [ ! -f /etc/issue.d/password.issue ]; then PASSWORD=$(tr -dc A-HJ-Xa-km-x2-9 < /dev/urandom | head -c 12); printf "%%s\n" "$PASSWORD" | passwd --stdin root; printf "Initial root password: $PASSWORD\n\n" > /etc/issue.d/password.issue; passwd -e root; fi'
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

  provisioner "shell" {
    only = ["qemu.rl"]
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    inline = [
      "echo 'rm -f /etc/issue.d/password.issue ; sed -i \"\\+rm -f /etc/issue.d/password.issue+ d\" /root/.bash_profile' >> /root/.bash_profile",
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
