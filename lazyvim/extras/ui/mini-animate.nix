_self: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.programs.lazyvim;
in {
  options.programs.lazyvim.extras.ui.mini-animate = {
    enable = mkEnableOption "the ui.mini-animate extra";
  };

  config = mkIf cfg.extras.ui.mini-animate.enable {
    programs.neovim = {
      plugins = [pkgs.vimPlugins.mini-animate];
    };
  };
}
