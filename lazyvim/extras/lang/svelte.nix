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
  options.programs.lazyvim.extras.lang.svelte = {
    enable = mkEnableOption "the lang.svelte extra";
  };

  config = mkIf cfg.extras.lang.svelte.enable {
    programs.neovim = {
      extraPackages = [ pkgs.nodePackages.svelte-language-server ];

      plugins = [ (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: [ plugins.svelte ])) ];
    };
  };
}
