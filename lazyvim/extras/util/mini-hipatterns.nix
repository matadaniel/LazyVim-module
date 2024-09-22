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
  options.programs.lazyvim.extras.util.mini-hipatterns = {
    enable = mkEnableOption "the util.mini-hipatterns extra";
  };

  config = mkIf cfg.extras.util.mini-hipatterns.enable {
    programs.neovim = {
      plugins = [
        (pkgs.vimUtils.buildVimPlugin {
          pname = "mini.hipatterns";
          version = "2024-06-23";
          src = inputs.mini-hipatterns;
        })
      ];
    };
  };
}
