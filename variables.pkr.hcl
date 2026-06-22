variable "repodata_url" {
  default = "https://distfeed.nethserver.org/ns8/updates/repodata.json"
  type    = string
}

variable "docker_registry" {
  default = "docker.io/registry:3"
  type    = string
}
