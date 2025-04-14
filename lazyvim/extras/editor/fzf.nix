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
  options.programs.lazyvim.extras.editor.fzf = {
    enable = mkEnableOption "the editor.fzf extra";
  };

  config = mkIf cfg.extras.editor.fzf.enable {
    programs.neovim = {
      plugins = [ pkgs.vimPlugins.fzf-lua ];
    };
  };
}
