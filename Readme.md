# NS8 images

[HashiCorp Packer](https://www.packer.io/) configuration for create a NethServer 8 image.

## Build

Prerequisites
* packer: https://developer.hashicorp.com/packer/downloads
* qemu for qcow2 images: https://www.qemu.org/

### Qcow2 images

Supported Distro:

* Debian 12 (`qemu.dn`)
* Centos Stream 9.1 (`qemu.cs`)
* RocKy Linux 9.1 (qemu.rl')
* Alma Linux 9.1 (`qemu.al`)

Build all images:

```
packer build --only="qemu.*" .
```

A specific image:

```
packer build --only="qemu.cs" .
```
### DigitalOcean snapshots

Supported Distro:

* Centos Stream 9.1
* RocKy Linux 9.1
* Alma Linux 9.1

Build all images:

```
export DIGITALOCEAN_TOKEN=<DO_TOKEN>
packer build --only="digitalocean.*" .
```

A specific image:

```
packer build --only="digitalocean.cs" .
```
