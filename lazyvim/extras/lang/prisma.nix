_self: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.programs.lazyvim;
in {
  options.programs.lazyvim.extras.lang.prisma = {
    enable = mkEnableOption "the lang.prisma extra";
  };

  config = mkIf cfg.extras.lang.prisma.enable {
    programs.neovim = {
      extraPackages = [pkgs.nodePackages."@prisma/language-server"];

      plugins = [(pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: [plugins.prisma]))];
    };
  };
}
