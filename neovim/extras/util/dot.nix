{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.neovim = {
    extraPackages = [
      pkgs.nodePackages.bash-language-server
      pkgs.shellcheck
    ];

    plugins = [
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (
        plugins:
        [ plugins.git_config ]
        ++ lib.optional config.wayland.windowManager.hyprland.enable plugins.hyprlang
        ++ lib.optional config.programs.fish.enable plugins.fish
        ++ lib.optional (config.programs.rofi.enable || config.programs.wofi.enable) plugins.rasi
      ))
    ];
  };
}
