let
  rev = "def8a134dc49ea5f9781418bee65beb311961e66";
  sha256 = "sha256:1k61h6v1d76yflcvzkrj370z8nzw8ibbgnvc1fdg973p4k63nlly";
  owner = "NixOS";
  repo = "nixpkgs";
in
import (fetchTarball {
  url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
  inherit sha256;
}) {}
