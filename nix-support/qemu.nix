{ qemu
, writeShellScript
, DiskImage
}:

# USB_BUS=... ADDITIONAL_DRIVE=... can be used to configure either a different USB bus or extra drive.
writeShellScript "run-vm" ''

#USB_BUS="usb-bus"
#USB_BUS="ehci"
# Bus used by the devices
USB_BUS="''${USB_BUS:-xhci}"

if test -n "$ADDITIONAL_DRIVE"; then
  ADDITIONAL_DRIVE=(
    -drive if=none,id=extradrive,format=raw,file="$ADDITIONAL_DRIVE"
    -device usb-storage,bus=$USB_BUS.0,drive=extradrive,removable=on
  )
else
  ADDITIONAL_DRIVE=(
  )
fi

ARGS=(
	"${qemu}"/bin/qemu-system-x86_64
	-enable-kvm

	-smp 4
	-m 512

	-snapshot
	-serial stdio
)

# As actual disks (not USB)
#ARGS+=(
#	-drive file=test.img,format=raw,index=0,media=disk
#	-drive file=nixos-minimal-new-kernel-no-zfs-24.05pre582649.d934204a0f8d-x86_64-linux.iso,format=raw,index=1,media=disk
#)

ARGS+=(
	# USB
	-usb                          # usb-bus
	-device usb-ehci,id=ehci      # ehci
	-device nec-usb-xhci,id=xhci  # xhci

	-device usb-tablet,bus=$USB_BUS.0
	-device usb-kbd,bus=$USB_BUS.0
)

if [[ "$USB_BUS" != "xhci" ]]; then
  ARGS+=( "''${ADDITIONAL_DRIVE[@]}" )
fi

ARGS+=(
	-drive if=none,id=openduet,format=raw,readonly=on,file=${DiskImage}
	-device usb-storage,bus=$USB_BUS.0,drive=openduet,removable=on
)

if [[ "$USB_BUS" == "xhci" ]]; then
  ARGS+=( "''${ADDITIONAL_DRIVE[@]}" )
fi

PS4=" $ "
set -x
"''${ARGS[@]}" "$@"

''
