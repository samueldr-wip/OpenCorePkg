{ pkgs
, configuration ? {}
}:

import (pkgs.path + "/nixos") {
  configuration = {
    imports = [
      (pkgs.path + "/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix")
      configuration
    ];
  };
}
