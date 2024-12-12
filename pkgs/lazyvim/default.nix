{
  pkgs,
  lib,
  inputs,
  self,
}:
let
  evalLazyVimModule =
    config:
    lib.evalModules {
      modules = [
        (import ./module.nix self)
        (self.homeManagerModules.lazyvim)
      ];
      specialArgs = {
        inherit
          inputs
          lib
          pkgs
          config
          ;
      };
    };

  defaultConfig = import ./config.nix;
  lazyvimConfig = (evalLazyVimModule defaultConfig).config;

  xdgConfigFile = lazyvimConfig.xdg.configFile;
  filteredConfigFiles = pkgs.lib.filterAttrs (
    name: value: pkgs.lib.hasPrefix "nvim/lua/plugins" name
  ) xdgConfigFile;
  writtenConfigFiles = pkgs.lib.mapAttrsToList (
    name: value:
    if pkgs.lib.hasAttr "text" value && value.text != null then
      pkgs.writeText name value.text
    else if pkgs.lib.hasAttr "source" value && value.source != null then
      pkgs.runCommandNoCC name { } "cp ${value.source} $out"
    else
      throw "Invalid configFile: ${name}"
  ) filteredConfigFiles;
  xdgConfigDerivation = pkgs.stdenv.mkDerivation {
    name = "xdg-nvim-config-files";
    buildCommand = ''
      mkdir $out
      for file in ${pkgs.lib.concatStringsSep " " writtenConfigFiles}; do
        cp $file $out
      done
    '';
  };

  neovimConfig = lazyvimConfig.programs.neovim;
  lazyvim = pkgs.wrapNeovim pkgs.neovim-unwrapped {
    configure = {
      customRC = # vim
        ''
          lua << EOF
            ${neovimConfig.extraLuaConfig}
          EOF
        '';
      packages.myNeovimPackages = {
        start = neovimConfig.plugins;
      };
    };
  };
in
pkgs.writeShellScriptBin "neovim" ''
  export XDG_CONFIG_HOME=$(mktemp -d)
  pluginsDir=$XDG_CONFIG_HOME/nvim/lua/plugins
  mkdir -p $pluginsDir
  ln -sf ${xdgConfigDerivation}/* $pluginsDir

  export PATH="$PATH:${pkgs.lib.makeBinPath neovimConfig.extraPackages}"
  exec ${lazyvim}/bin/nvim "$@"
''
