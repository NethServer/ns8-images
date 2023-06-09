source "digitalocean" "dn" {
  image         = "debian-11-x64"
  region        = "ams3"
  size          = "s-1vcpu-1gb"
  ssh_username  = "root"
  snapshot_name = "ns8-debian-11-${var.core_version}"
}

source "digitalocean" "rl" {
  image         = "rockylinux-9-x64"
  region        = "ams3"
  size          = "s-1vcpu-1gb"
  ssh_username  = "root"
  snapshot_name = "ns8-rockylinux-9-${var.core_version}"

}

source "digitalocean" "cs" {
  image         = "centos-stream-9-x64"
  region        = "ams3"
  size          = "s-1vcpu-1gb"
  ssh_username  = "root"
  snapshot_name = "ns8-centos-stream-9-${var.core_version}"

}

source "digitalocean" "al" {
  image         = "almalinux-9-x64"
  region        = "ams3"
  size          = "s-1vcpu-1gb"
  ssh_username  = "root"
  snapshot_name = "ns8-almalinux-9-${var.core_version}"

}
