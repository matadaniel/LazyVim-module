{
  pkgs,
  lib,
  inputs,
  self,
}:
let
  lazyvim-module-evaluation = lib.evalModules {
    modules = [
      (self.nixosModules.lazyvim)
      (self.homeManagerModules.lazyvim)
    ];
    specialArgs = {
      inherit
        inputs
        lib
        pkgs
        ;
      config = import ./config.nix;
    };
  };

  programs = lazyvim-module-evaluation.config.programs;
  neovim-config = programs.neovim;
  lazyvim = pkgs.wrapNeovim pkgs.neovim-unwrapped {
    configure = {
      customRC = # vim
        ''
          lua << EOF
            ${neovim-config.extraLuaConfig}
          EOF
        '';
      packages.myNeovimPackages = {
        start = neovim-config.plugins;
      };
    };
  };
in
pkgs.writeShellScriptBin "neovim" ''
  export PATH="$PATH:${pkgs.lib.makeBinPath neovim-config.extraPackages}"
  export NVIM_APPNAME="LazyVim-module-app"
  exec ${lazyvim}/bin/nvim "$@"
''
