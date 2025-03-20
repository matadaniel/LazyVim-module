let
  plugins = import ../lazyvim/plugins/lib;
  strings = import ./strings.nix;
in
{
  inherit (plugins) buildVimPlugin buildVimPlugins;
  inherit (strings) formatList hasNvimVersion;

  inherit plugins;
  inherit strings;
}
