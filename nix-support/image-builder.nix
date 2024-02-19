let
  rev = "56e55df7b07b5e5c6d050732d851cec62b41df95";
  sha256 = "sha256:1v81r1a0g93mc0r3lqima4qgxl2f2fccknmx5nhaws2r65y7ngqs";
  owner = "NixOS";
  repo = "mobile-nixos";

  src = fetchTarball {
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in
import (src + "/overlay/image-builder")
