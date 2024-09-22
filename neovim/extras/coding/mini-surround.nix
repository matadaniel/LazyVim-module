self:
{
  config,
  inputs,
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
  options.programs.lazyvim.extras.coding.mini-surround = {
    enable = mkEnableOption "the coding.mini-surround extra";
  };

  config = mkIf cfg.extras.coding.mini-surround.enable {
    programs.neovim = {
      plugins = [
        (pkgs.vimUtils.buildVimPlugin {
          pname = "mini.surround";
          version = "2024-06-23";
          src = inputs.mini-surround;
        })
      ];
    };
  };
}
