data "sshkey" "install" {}

data "http" "versions" {
  url = var.repodata_url
}
