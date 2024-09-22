self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.programs.lazyvim;
in
{
  options.programs.lazyvim.extras.editor.inc-rename = {
    enable = mkEnableOption "the editor.inc-rename extra";
  };

  config = mkIf cfg.extras.editor.inc-rename.enable {
    programs.neovim = {
      plugins = [ pkgs.vimPlugins.inc-rename-nvim ];
    };
  };
}
