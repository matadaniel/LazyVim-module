self: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) attrValues;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.programs.lazyvim;
in {
  options.programs.lazyvim.extras.coding.mini-snippets = {
    enable = mkEnableOption "the coding.mini-snippets extra";
  };

  config = mkIf cfg.extras.coding.mini-snippets.enable {
    programs.neovim = {
      # TODO: remove luasnip and nvim-snippets
      plugins = attrValues {inherit (pkgs.vimPlugins) friendly-snippets mini-snippets;};
      # TODO: ++ optional cfg.extras.coding.nvim-cmp.enable (
      #   buildVimPlugin inputs pkgs {
      #     pname = "cmp-mini-snippets";
      #     dependencies = [ pkgs.vimPlugins.nvim-cmp ];
      #   }
      # );
    };
  };
}
