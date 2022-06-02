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
qemu-system-x86_64 -hda obsd.qcow2 -cdrom install71.iso -monitor stdio
```

## 4. Install

keyboard:
hostname: **obsd**
net iface conf:
ipv4:
ipv6:
net iface conf:
root pwd: root
sshd autostart:
run X:
started by xenodm: **yes**
default console:
user: **pol**
fullname:
password: pol
ssh root login: **yes**
timezone:
root disk:
whole disk MBR:
auto layout:
location of sets:
pathname:
select sets:
continue without verif: **yes**
location of sets:

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

## 6. Setup doas

```
# in /etc/doas.conf
permit nopass keepenv setenv { PATH } pol as root
```

## 7. Update and install

```sh
TERM=xterm doas pkg_add vim kitty node git wget
```

## 8. my config

```sh
git clone https://github.com/mthfrr/config.git
cp config/.kshrc .
echo ". ~/.kshrc" >> .profile
```
