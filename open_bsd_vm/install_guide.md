# Qemu OpenBSD VM

source: https://yotsev.xyz/sysadmin/obsd-vm.html

## 1. Get the iso

```sh
wget https://cdn.openbsd.org/pub/OpenBSD/7.1/amd64/install71.iso
```

## 2. Create disk

30G is the max size

```sh
qemu-img create -f qcow2 obsd.qcow2 30G
```

## 3. Start the vm and run the installer

```sh
qemu-system-x86_64 -hda obsd.qcow2 -cdrom install71.iso -monitor stdio -display sdl
```

## 4. Install

...

## 5. Setup ssh

Start the vm

```sh
qemu-system-x86_64 -hda obsd.qcow2 -nic user,hostfwd=tcp::10022-:22
```

Then from host

```sh
ssh-copy-id -p 10022 root@localhost
```

`halt -p` to power off

## 6. Install stuff

upgrade

```sh
TERM=xterm pkg_add -u
```

### Setup ports

```sh
cd /tmp
ftp https://cdn.openbsd.org/pub/OpenBSD/$(uname -r)/{ports.tar.gz,SHA256.sig}
signify -Cp /etc/signify/openbsd-$(uname -r | cut -c 1,3)-base.pub -x SHA256.sig ports.tar.gz

cd /usr
tar xzf /tmp/ports.tar.gz
```

### Install with ports

```sh
pkg_add portslist
```
