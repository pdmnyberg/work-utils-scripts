#!/bin/bash

export HELP_TEXT="This script contains a number of \
utility functions that aims to simplify using vms on the command line:"

_setup_vm_actions() {
    source "${SCRIPTS}/core.sh"

    DISKS="vms/disks"
    ISOS="vms/isos"

    run() {
        NAME="${1:-centos-15g}"
        PORT="${2:-2222}"
        HTTPS_PORT="${3:-4433}"
        HTTP_PORT="${4:-8080}"
        SYSTEM_DRIVE="$DISKS/${NAME}.qcow"

        echo "Using drive: ${SYSTEM_DRIVE}"

        qemu-system-x86_64 \
            -m 4096 \
            -enable-kvm \
            -snapshot \
            -cpu host \
            -drive file=$SYSTEM_DRIVE,id=system_disk \
            -device virtio-net-pci,netdev=unet \
            -netdev "user,id=unet,hostfwd=tcp::${PORT}-:22,hostfwd=tcp::${HTTPS_PORT}-:443,hostfwd=tcp::${HTTP_PORT}-:80"
    }

    list() {
        echo "# Available VM names:"
        for file in $DISKS/*.qcow; do
            echo "- `basename "$file" .qcow`"
        done
        echo "# Available ISOS:"
        for file in $ISOS/*.iso; do
            echo "- `basename "$file" .iso`"
        done
    }

    create-disk() {
        DISK_NAME="${1:-disk}"
        DISK_SIZE="${2:-15G}"
        DISK_PATH="$DISKS/${DISK_NAME}-${DISK_SIZE}.qcow"
        qemu-img create -f qcow2 "${DISK_PATH}" "${DISK_SIZE}"
    }

    create-vm() {
        OS_NAME="${1:-centos-stream-9}"
        DRIVE_SIZE="${3:-15G}"
        DRIVE_NAME="${2:-${OS_NAME}}-${DRIVE_SIZE}"

        echo "OS name: ${OS_NAME}"
        echo "Drive:"
        echo " - Size: ${DRIVE_SIZE}"
        echo " - Name: ${DRIVE_NAME}"

        ISO_PATH="$ISOS/${OS_NAME}.iso"
        DRIVE_PATH="$DISKS/${DRIVE_NAME}.qcow"
        qemu-img create -f qcow2 "${DRIVE_PATH}" "${DRIVE_SIZE}"

        qemu-system-x86_64 \
            -m 4096 \
            -enable-kvm \
            -cpu host \
            -cdrom $ISO_PATH \
            -drive file=$DRIVE_PATH,id=system_disk \
            -device virtio-net-pci,netdev=unet \
            -netdev user,id=unet,hostfwd=tcp::2222-:22
    }

    setup() {
        mkdir -p "$ISOS"
        mkdir -p "$DISKS"

        _require_distro "Debian GNU/Linux"
        sudo apt install qemu-system
    }

    _add_action "run" "Runs a named VM using qemu"
    _add_action "list" "Lists available vms"
    _add_action "create-disk" "Create a new disk image"
    _add_action "create-vm" "Start install on VM"
    _add_action "setup" "Set up vm environment"
}

vms() {
    _setup_vm_actions
    _run $@
}