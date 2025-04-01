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
  inherit (lib.lists) optional;

  cfg = config.programs.lazyvim;
in
{
  options.programs.lazyvim.extras.lang.rust = {
    enable = mkEnableOption "the lang.rust extra";
  };

  config = mkIf cfg.extras.lang.rust.enable {
    programs.neovim = {
      extraPackages = [pkgs.rust-analyzer] ++ optional cfg.extras.dap.core.enable [pkgs.lldb];

      plugins =
        [
          (pkgs.vimPlugins.nvim-treesitter.withPlugins (
            plugins: builtins.attrValues {inherit (plugins) rust;}
          ))
        ]
        ++ (with pkgs.vimPlugins; [
          crates-nvim
          rustaceanvim
          clangd_extensions-nvim
        ]);
    };
  };
}
