self: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.programs.lazyvim;
in {
  options.programs.lazyvim.extras.linting.eslint = {
    enable = mkEnableOption "the linting.eslint extra";
  };

  config = mkIf cfg.extras.linting.eslint.enable {
    programs.neovim = {
      extraPackages = [pkgs.vscode-langservers-extracted];
    };
  };
}
