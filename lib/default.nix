{lib}: let
  generators = import ./generators.nix {inherit lib;};
  options = import ./options.nix {inherit lib;};
  plugins = import ../lazyvim/plugins/lib;
  strings = import ./strings.nix {inherit lib;};
  types = import ./types.nix {inherit lib;};
in {
  inherit (generators) toLazySpecs;
  inherit (plugins) buildVimPlugin buildVimPlugins;
  inherit (strings) formatList hasNvimVersion;
  inherit (types) nested;

  inherit generators;
  inherit options;
  inherit plugins;
  inherit strings;
  inherit types;
}
