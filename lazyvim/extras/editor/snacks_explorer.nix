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
  options.programs.lazyvim.extras.editor.snacks_explorer = {
    enable = mkEnableOption "the editor.snacks_explorer extra";
  };

  config = mkIf cfg.extras.editor.snacks_explorer.enable {
    programs.neovim = {
      plugins = [ pkgs.vimPlugins.snacks-nvim ];
    };
  };
}
