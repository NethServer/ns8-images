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
      - root:Nethesis,1234
    EOT
  }
}

local repodata {
  expression = jsondecode(data.http.versions.body)
}

local core_component {
  expression = [for component in local.repodata : component if component.id == "core"][0]
}

local core_version {
  expression = split(
    "|",
    reverse(sort([
      for version in local.core_component.versions :
      "${join(".", [for part in regexall("[0-9]+", version.tag) : replace(format("%10s", part), " ", "0")])}|${version.tag}"
      if !version.testing
    ]))[0]
  )[1]
}

local core_module {
  expression = "${local.core_component.source}:${local.core_version}"
}

local traefik_component {
  expression = [for component in local.repodata : component if component.id == "traefik"][0]
}

local traefik_version {
  expression = split(
    "|",
    reverse(sort([
      for version in local.traefik_component.versions :
      "${join(".", [for part in regexall("[0-9]+", version.tag) : replace(format("%10s", part), " ", "0")])}|${version.tag}"
      if !version.testing
    ]))[0]
  )[1]
}

local traefik_module {
  expression = "${local.traefik_component.source}:${local.traefik_version}"
}
