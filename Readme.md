# NS8 images

[HashiCorp Packer](https://www.packer.io/) configuration for create a NethServer 8 image.

## Build

Prerequisites
* packer: https://developer.hashicorp.com/packer/downloads
* qemu for qcow2 images: https://www.qemu.org/

Prepare the environment, execute:
```
packer init .
```

### Qcow2 images

Supported Distro:

* Debian 12 (`qemu.dn`)
* RocKy Linux 9 (qemu.rl')

Build all images:

```
packer build --only="qemu.*" .
```

A specific image:

```
packer build --only="qemu.rl" .
```
### DigitalOcean snapshots

Supported Distro:

* RocKy Linux 9

Build all images:

```
export DIGITALOCEAN_TOKEN=<DO_TOKEN>
packer build --only="digitalocean.*" .
```

A specific image:

```
packer build --only="digitalocean.rl" .
```
