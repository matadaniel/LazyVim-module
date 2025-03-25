self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) attrValues;
  inherit (lib.modules) mkIf;
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.types) listOf package;
  inherit (self.lib.options) mkNotExtraOption;

  cfg = config.programs.lazyvim;
in
{
  options.programs.lazyvim.extras.editor.snacks_picker = {
    enable = mkEnableOption "the editor.snacks_picker extra";

    db = {
      sqlite3 = {
        enable = mkEnableOption "SQLite3 for frecency";
        extra = mkNotExtraOption;
      };
    };

    dependencies = mkOption {
      default = attrValues { inherit (pkgs) fd git ripgrep; };
      defaultText = literalExpression "[ pkgs.fd pkgs.git pkgs.ripgrep ]";
      description = "List of packages to make available to Neovim.";
      type = listOf package;
    };
  };

  config = mkIf cfg.extras.editor.snacks_picker.enable {
    programs.lazyvim = {
      lazySpecs = {
        extras.editor.snacks_picker = mkIf cfg.extras.editor.snacks_picker.db.sqlite3.enable [
          {
            ref = "folke/snacks.nvim";
            opts.picker.db.sqlite3_path = "${pkgs.sqlite.out}/lib/libsqlite3${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}";
          }
        ];
      };
    };

    programs.neovim = {
      extraPackages = cfg.extras.editor.snacks_picker.dependencies;

      plugins = [ pkgs.vimPlugins.snacks-nvim ];
    };
  };
}
