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
      plugins = [ pkgs.vimPlugins.snacks-nvim ];
    };
  };
}
