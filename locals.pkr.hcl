local cloud-init {
  expression = {
    "/meta-data"   = ""
    "/vendor-data" = ""
    "/user-data"   = <<-EOT
    #cloud-config
    fqdn: node.ns8.test
    manage_etc_hosts: localhost
    ssh_pwauth: True
    ssh_authorized_keys:
      - ${data.sshkey.install.public_key}
    chpasswd:
      expire: True
      list:
      - root:RANDOM
    EOT
  }
}

local core_module {
  expression = "${var.core_url}:${var.core_version}"
}
