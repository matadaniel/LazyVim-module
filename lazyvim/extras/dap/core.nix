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
  options.programs.lazyvim.extras.dap.core = {
    enable = mkEnableOption "the dap.core extra";
  };

  config = mkIf cfg.extras.dap.core.enable {
    programs.neovim = {
      plugins = builtins.attrValues {
        inherit
          (pkgs.vimPlugins)
          nvim-dap
          nvim-dap-ui
          nvim-dap-virtual-text
          nvim-nio
          ;
      };
    };
  };
}
