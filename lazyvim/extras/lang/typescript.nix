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
  options.programs.lazyvim.extras.lang.typescript = {
    enable = mkEnableOption "the lang.typescript extra";
  };

  config =
    mkIf
      (
        let
          inherit (cfg.extras.lang) astro svelte typescript;
        in
        astro.enable || svelte.enable || typescript.enable
      )
      {
        programs.neovim = {
          extraPackages = [ pkgs.vtsls ];
        };
      };
}
