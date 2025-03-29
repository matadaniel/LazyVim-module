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
  options.programs.lazyvim.extras.editor.dial = {
    enable = mkEnableOption "the editor.dial extra";
  };

  config = mkIf cfg.extras.editor.dial.enable {
    programs.neovim = {
      plugins = [pkgs.vimPlugins.dial-nvim];
    };
  };
}
