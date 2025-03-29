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
  options.programs.lazyvim.extras.test.core = {
    enable = mkEnableOption "the test.core extra";
  };

  config = mkIf cfg.extras.test.core.enable {
    programs.neovim = {
      plugins = builtins.attrValues {inherit (pkgs.vimPlugins) neotest nvim-nio;};
    };
  };
}
