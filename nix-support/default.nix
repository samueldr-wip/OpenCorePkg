(import ./pkgs.nix).callPackage (

{ callPackage }:

let
  image-builder = callPackage ./image-builder.nix {};
in
{
  OpenDuet = callPackage ./openduet.nix {};
}

) {}
