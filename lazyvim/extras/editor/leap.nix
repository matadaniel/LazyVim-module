self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) attrValues;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.programs.lazyvim;
in
{
  options.programs.lazyvim.extras.editor.leap = {
    enable = mkEnableOption "the editor.leap extra";
  };

  config = mkIf cfg.extras.editor.leap.enable {
    programs.neovim = {
      plugins = attrValues { inherit (pkgs.vimPlugins) flit-nvim leap-nvim vim-repeat; };
    };
  };
}
