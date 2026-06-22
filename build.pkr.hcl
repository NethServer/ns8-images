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

  provisioner "file" {
    content     = <<-EOT
    [[registry]]
    location = "127.0.0.1:5000"
    insecure = true # allow push over plain-HTTP

    [[registry]]
    location = "docker.io"
    [[registry.mirror]]
    location = "127.0.0.1:5000/docker.io"
    insecure = true
    [[registry.mirror]]
    location = "ghcr.io/nethserver/docker.io"
    EOT
    destination = "/tmp/801-local-registry.conf"
  }

  provisioner "file" {
    content     = <<-EOT
    install -v -t /etc/containers/registries.conf.d/ /tmp/801-local-registry.conf
    rm -vf /tmp/801-local-registry.conf
    podman pull ${var.docker_registry}
    podman pull ${local.traefik_module}
    podman run -d --rm \
      --init \
      --network=host \
      --name local-registry \
      --volume local-registry:/var/lib/registry:z \
      ${var.docker_registry}
    until curl -fs http://127.0.0.1:5000/v2/ >/dev/null 2>&1; do sleep 1 ; done
    module_images=($(podman image inspect "${local.traefik_module}" | jq -r '.[0].Labels["org.nethserver.images"]'))
    for image in "$${module_images[@]}" ; do
      image_id=$(podman pull "$${image}")
      # Normalize docker.io/image:tag -> docker.io/library/image:tag
      image=$(podman image inspect "$${image_id}" | jq -r '.[0].RepoTags[0]')
      podman tag "$${image}" "127.0.0.1:5000/$${image}"
      podman push "127.0.0.1:5000/$${image}"
      podman rmi "$${image}"
      podman rmi "127.0.0.1:5000/$${image}"
    done
    podman stop local-registry
    rm -vf /tmp/local-registry-init.sh
    EOT
    destination = "/tmp/local-registry-init.sh"
  }

  provisioner "shell" {
    env = {
      "NS8_TWO_STEPS_INSTALL" : "1"
    }
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    expect_disconnect = true
    inline = [
      "curl https://raw.githubusercontent.com/NethServer/ns8-core/ns8-stable/core/install.sh | bash -s ${local.core_module} ${local.traefik_module}",
      "bash -x /tmp/local-registry-init.sh",
      "printf 'Setup in progress. Type Ctrl+D to refresh this prompt.\n\n' > /etc/issue.d/password.issue",
    ]
  }

  provisioner "file" {
    content     = <<-EOT
    [Unit]
    Description=Local Image Registry Cache
    [Service]
    Type=forking
    ExecStart=podman run --detach \
      --rm \
      --replace \
      --init \
      --cgroups=no-conmon \
      --network=host \
      --name local-registry \
      --volume local-registry:/var/lib/registry:z \
      ${var.docker_registry}
    SuccessExitStatus=143
    ExecStartPost=bash -c 'until curl -fs http://127.0.0.1:5000/v2/ >/dev/null 2>&1; do sleep 1 ; done'
    ExecStop=podman stop --ignore -t 10 local-registry
    EOT
    destination = "/tmp/local-registry.service"
  }

  provisioner "file" {
    content     = <<-EOT
    [Unit]
    Wants=network-online.target local-registry.service
    After=network-online.target local-registry.service
    [Service]
    Type=oneshot
    ExecStart=/bin/bash -c 'PASSWORD=$(tr -dc A-HJ-Xa-km-x2-9 < /dev/urandom | head -c 12); printf "%%s\n" "$PASSWORD" | passwd --stdin root; printf "Initial root password: $PASSWORD\n\n" > /etc/issue.d/password.issue; passwd -e root'
    ExecStart=/bin/bash /var/lib/nethserver/node/install-finalize.sh ${local.traefik_module}
    ExecStart=/usr/bin/systemctl disable ns8-install-finalize.service
    ExecStart=/usr/bin/systemctl stop local-registry
    ExecStart=podman volume rm -f local-registry
    ExecStart=podman rmi ${var.docker_registry}
    ExecStart=/usr/bin/rm -f \
      /etc/systemd/system/ns8-install-finalize.service \
      /etc/systemd/system/local-registry.service \
      /etc/containers/registries.conf.d/801-local-registry.conf
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
      "install -v -t /etc/systemd/system/ /tmp/*.service",
      "rm -vf /tmp/*.service",
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
