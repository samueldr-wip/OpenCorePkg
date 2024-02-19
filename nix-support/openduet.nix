{ lib
, runCommand
, fetchpatch
, fetchFromGitHub
, edk2
, acpica-tools
, nasm
, zip

# Source from Acidanthera's UDK or a fork thereof
, audkSrc ? fetchFromGitHub {
    owner = "samueldr-wip";
    repo = "edk2";
    rev = "220d6155963c7c0bb8d3c0aa3d95c0a04a25f630";
    fetchSubmodules = true; # sigh
    hash = "sha256-VLpY2cHS4uHlzXgw3Ee6q74u3W4b2/J9NC/7c8ao6r4=";
  }
# OpenCorePkg, which is what this directory should be a checkout of.
, ocSrc ? builtins.fetchGit ../.
}:

let
  opencore =
    (edk2.override({ buildType = "GCC"; }))
    .overrideAttrs({ env, ...}: {
      patches = [];
      src = runCommand "audk-with-opencore" { } ''
        cp --no-preserve=mode -r ${audkSrc} $out
        # audk has a submodule for it... replace with our checkout
        rm -rf $out/OpenCorePkg
        cp --no-preserve=mode -r ${ocSrc} $out/OpenCorePkg
        chmod -R +w $out/
      ''
    ;

    env.NIX_CFLAGS_COMPILE =
      env.NIX_CFLAGS_COMPILE
      + " -Wno-error"
    ;
  });
in
opencore.mkDerivation "OpenCorePkg/OpenDuetPkg.dsc" (finalAttrs: {
  pname = "OpenDuet-StandAlone";
  version = "unstable-000000";
  inherit (opencore) src;
  edk2 = opencore;

  buildConfig = "RELEASE";

  nativeBuildInputs = edk2.nativeBuildInputs ++ [
    acpica-tools
    nasm
    zip
  ];

  postBuild = ''
    echo
    echo :: Calling build_duet.tool
    echo
    export BUILD_DIR="$PWD/Build/OpenDuetPkg/''${buildConfig}_GCC"
    export BUILD_DIR_ARCH="$BUILD_DIR/${edk2.targetArch}"
    (
    set -x
    cd OpenCorePkg
    bash -x build_duet.tool imgbuild ${edk2.targetArch}
    )
    (
    set -x
    cd OpenCorePkg/Legacy/BootLoader/
    make
    mv -vt "$BUILD_DIR_ARCH" bin/*
    )
  '';

  passthru = {
    inherit opencore;
  };

  dontFixup = true;

  # From the OVMF derivation
  hardeningDisable = [ "all" ];
})
