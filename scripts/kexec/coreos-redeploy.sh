#! /bin/sh -e

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

ISO_URL=$1
MOUNT='mount -o loop,ro image'
KERNEL='images/vmlinuz'
INITRD='images/initramfs.img'
SQASHFS='root.squashfs'
KERNEL_ARG='random.trust_cpu=on rd.luks.options=discard coreos.liveiso=rhcos-46.82.202007071437-0 ignition.firstboot ignition.platform.id=metal'
KEXEC_PATH='/usr/local/bin'
KEXEC_IMG='quay.io/ohadlevy/kexec'

podman run --privileged --rm -v $KEXEC_PATH:/hostbin $KEXEC_IMG cp /kexec /hostbin

TMP=$(mktemp -d)

cd $TMP
mkdir mnt
curl -O $ISO_URL
$MOUNT mnt && cd mnt

printf '%s %s\n' "$(date)" "$line"
echo kexecing $(hostname)... rebooting.

cat $INITRD $SQASHFS > /tmp/initrd
$KEXEC_PATH/kexec --force --reset-vga -d --initrd=/tmp/initrd --append="$KERNEL_ARG" $KERNEL
