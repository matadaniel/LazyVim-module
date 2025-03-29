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
  options.programs.lazyvim.extras.util.dot = {
    enable = mkEnableOption "the util.dot extra";
  };

  config = mkIf cfg.extras.util.dot.enable {
    programs.neovim = {
      extraPackages = [
        pkgs.bash-language-server
        # shellcheck included in bash-language-server
        # pkgs.shellcheck
      ];

      plugins = [
        (pkgs.vimPlugins.nvim-treesitter.withPlugins (
          plugins:
            [plugins.git_config]
            ++ lib.optional config.wayland.windowManager.hyprland.enable plugins.hyprlang
            ++ lib.optional config.programs.fish.enable plugins.fish
            ++ lib.optional (config.programs.rofi.enable || config.programs.wofi.enable) plugins.rasi
        ))
      ];
    };
  };
}
