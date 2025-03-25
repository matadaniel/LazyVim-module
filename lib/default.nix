{ lib }:
let
  plugins = import ../lazyvim/plugins/lib;
  strings = import ./strings.nix { inherit lib; };
in
{
  inherit (plugins) buildVimPlugin buildVimPlugins;
  inherit (strings) formatList hasNvimVersion;

  inherit plugins;
  inherit strings;
}
