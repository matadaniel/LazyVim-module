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
  options.programs.lazyvim.extras.lang.tailwind = {
    enable = mkEnableOption "the lang.tailwind extra";
  };

  config = mkIf cfg.extras.lang.tailwind.enable {
    programs.neovim = {
      extraPackages = [ pkgs.tailwindcss-language-server ];

      plugins = [
        (pkgs.vimUtils.buildVimPlugin {
          pname = "tailwindcss-colorizer-cmp.nvim";
          version = "2024-06-23";
          src = inputs.tailwindcss-colorizer-cmp-nvim;
        })
      ];
    };
  };
}
