(import ./pkgs.nix).callPackage (

{ callPackage }:

let
  image-builder = callPackage ./image-builder.nix {};
in
rec {
  OpenDuet = callPackage ./openduet.nix {};
  DiskImage = callPackage ./diskimage.nix {
    inherit
      image-builder
      OpenDuet
    ;
  };
}

) {}
