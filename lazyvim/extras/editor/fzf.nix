_self: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.types) listOf package;

  cfg = config.programs.lazyvim;
in {
  options.programs.lazyvim.extras.editor.fzf = {
    enable = mkEnableOption "the editor.fzf extra";

    dependencies = mkOption {
      default = builtins.attrValues {inherit (pkgs) fd fzf ripgrep;};
      defaultText = literalExpression "[ pkgs.fd pkgs.fzf pkgs.ripgrep ]";
      description = ''
        List of packages to make available to Neovim.

        Check out `:help fzf-lua-dependencies` for more info.
        (LazyVim already configures mini.icons and `previewer.builtin.extensions`.)
      '';
      type = listOf package;
    };
  };

  config = mkIf cfg.extras.editor.fzf.enable {
    programs.neovim = {
      extraPackages = cfg.extras.editor.fzf.dependencies;

      plugins = [pkgs.vimPlugins.fzf-lua];
    };
  };
}
