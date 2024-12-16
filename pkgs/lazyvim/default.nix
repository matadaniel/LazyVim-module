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

  filteredConfigFiles = lib.filterAttrs (
    name: value: lib.hasPrefix "nvim/lua/plugins" name
  ) xdgConfigFile;

  writtenConfigFiles = lib.mapAttrsToList (
    name: value:
    if lib.hasAttr "text" value && value.text != null then
      pkgs.writeText name value.text
    else if lib.hasAttr "source" value && value.source != null then
      pkgs.runCommandNoCC name { } "cp ${value.source} $out"
    else
      throw "Invalid configFile: ${name}"
  ) filteredConfigFiles;

  xdgConfigDerivation = pkgs.stdenv.mkDerivation {
    name = "xdg-nvim-config-files";
    buildCommand = ''
      mkdir $out
      for file in ${lib.concatStringsSep " " writtenConfigFiles}; do
        cp $file $out
      done
    '';
  };

  neovimConfig = lazyvimConfig.programs.neovim;
  extraPackages =
    neovimConfig.extraPackages
    ++ (lib.optional defaultConfig.programs.lazygit.enable pkgs.lazygit)
    ++ (lib.optional defaultConfig.programs.ripgrep.enable pkgs.ripgrep);

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
  mkdir $XDG_CONFIG_HOME/lazygit
  touch $XDG_CONFIG_HOME/lazygit/config.yml
  pluginsDir=$XDG_CONFIG_HOME/nvim/lua/plugins
  mkdir -p $pluginsDir
  ln -sf ${xdgConfigDerivation}/* $pluginsDir

  export PATH="$PATH:${lib.makeBinPath extraPackages}"
  exec ${lazyvim}/bin/nvim "$@"
''
