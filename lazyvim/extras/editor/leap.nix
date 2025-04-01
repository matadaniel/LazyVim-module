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
  options.programs.lazyvim.extras.editor.leap = {
    enable = mkEnableOption "the editor.leap extra";
  };

  config = mkIf cfg.extras.editor.leap.enable {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [leap-nvim flit-nvim vim-repeat];
    };
  };
}
