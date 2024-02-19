(import ./pkgs.nix).callPackage (

{ callPackage }:

{
  OpenDuet = callPackage ./openduet.nix {};
}

) {}
