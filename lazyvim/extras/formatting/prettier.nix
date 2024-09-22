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
  options.programs.lazyvim.extras.formatting.prettier = {
    enable = mkEnableOption "the formatting.prettier extra";
  };

  config = mkIf cfg.extras.formatting.prettier.enable {
    programs.neovim = {
      extraPackages = [ pkgs.nodePackages.prettier ];
    };
  };
}
