variable "repodata_url" {
  default = "https://distfeed.nethserver.org/ns8/updates/repodata.json"
  type    = string
}

variable "core_version" {
  default     = ""
  type        = string
  description = "Core image tag to install. If empty, use the latest stable tag in repodata"
}

variable "docker_registry" {
  default = "docker.io/registry:3"
  type    = string
}
