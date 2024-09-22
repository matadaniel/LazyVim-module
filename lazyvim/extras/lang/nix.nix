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
  options.programs.lazyvim.extras.lang.nix = {
    enable = mkEnableOption "the lang.nix extra";
  };

  config = mkIf cfg.extras.lang.nix.enable {
    programs.neovim = {
      extraPackages = builtins.attrValues { inherit (pkgs) nil nixfmt-rfc-style; };

      plugins = [ (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: [ plugins.nix ])) ];
    };
  };
}
