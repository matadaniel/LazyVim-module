self: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.programs.lazyvim;
in {
  options.programs.lazyvim.extras.lang.json = {
    enable = mkEnableOption "the lang.json extra";
  };

  config = mkIf cfg.extras.lang.json.enable {
    programs.neovim = {
      extraPackages = [pkgs.vscode-langservers-extracted];

      plugins = [
        (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: [plugins.json5]))
        pkgs.vimPlugins.SchemaStore-nvim
      ];
    };
  };
}
