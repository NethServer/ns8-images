source "digitalocean" "dn" {
  image         = "debian-12-x64"
  region        = "ams3"
  size          = "s-1vcpu-1gb"
  ssh_username  = "root"
  snapshot_name = "ns8-debian-12-${var.core_version}"
}

source "digitalocean" "rl" {
  image         = "rockylinux-9-x64"
  region        = "ams3"
  size          = "s-1vcpu-1gb"
  ssh_username  = "root"
  snapshot_name = "ns8-rockylinux-9-${var.core_version}"

}
