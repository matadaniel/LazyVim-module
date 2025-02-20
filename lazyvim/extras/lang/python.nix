self:
{ config
, lib
, pkgs
, ...
}:

let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.programs.lazyvim;
in
{

  options.programs.lazyvim.extras.lang.python = {
    enable = mkEnableOption "the lang.python extra";
  };

  config = mkIf cfg.extras.lang.python.enable {
    programs.neovim = {

      extraPackages = with pkgs; [
        pyright
        ruff-lsp
        python312Packages.debugpy
      ];

      plugins = [
        (pkgs.vimPlugins.nvim-treesitter.withPlugins (
          plugins: builtins.attrValues {
            inherit (plugins)
              python
              ninja
              rst;
          }
        ))
      ];
    };
  };
}
