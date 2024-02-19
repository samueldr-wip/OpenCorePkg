{ image-builder
, lib
, OpenDuet
, refind
, systemd
, edk2-uefi-shell
# "-blockio" is the other current variant.
, variant ? ""
}:

let
  inherit (OpenDuet) edk2;
  inherit (lib)
    mkBefore
    mkDefault
  ;
  inherit (image-builder.helpers)
    makeESP
    size
  ;
  eval = image-builder.evaluateDiskImage {
    config = {
      name = "OpenDuet.img";
      partitioningScheme = mkDefault "gpt";
      partitions = mkBefore [
        (makeESP {
          name = "ESP";
          partitionLabel = "ESP";
          partitionUUID = "6244CF34-6513-4CC7-959F-0A0CB0CE9BC7";
          filesystem = {
            fat32.partitionID = "ef00ef00";
            # NOTE: minimum usable size is ~64MiB
            #       we're making it bigger so it's a minimally useful ESP for testing and such...
            #       ... while still fitting on a 512MiB drive.
            size = size.MiB 500;
            populateCommands = ''
              cp -v "${OpenDuet}/${edk2.targetArch}/boot${variant}" boot
              mkdir -p EFI/TOOLS
              cp -v "${edk2-uefi-shell}/shell.efi" "EFI/TOOLS/SHELL${edk2.targetArch}.EFI"
              mkdir -p EFI/MISC/
              cp -v "${systemd}/lib/systemd/boot/efi/systemd-bootx64.efi" "EFI/MISC/systemd-bootx64.efi"
              mkdir -p EFI/OC/
              cp -v ${refind}/share/refind/refind_x64.efi "EFI/OC/OpenCore.efi"
            '';
            additionalCommands = ''
              # Write the jmp instruction from boot1f32 first
              dd if="${OpenDuet}/${edk2.targetArch}/boot1f32" of="$img" bs=1 count=3 conv=notrunc
              # Write the boot program next (starts at 0x05A)
              dd if="${OpenDuet}/${edk2.targetArch}/boot1f32" of="$img" bs=1 count=420 seek=$((0x05A)) skip=$((0x05A)) conv=notrunc
            '';
          };
        })
      ];
      additionalCommands = ''
        dd if="${OpenDuet}/${edk2.targetArch}/boot0" of="$img" bs=1 count=446 conv=notrunc
      '';
    };
  };
in
eval.config.output // { inherit eval; }
