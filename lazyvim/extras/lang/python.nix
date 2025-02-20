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

      plugins = with pkgs.vimPlugins; [
        (nvim-treesitter.withPlugins (
          plugins: builtins.attrValues {
            inherit (plugins)
              python
              ninja
              rst;
          }
        ))
        (pkgs.vimUtils.buildVimPlugin {
          pname = "venv-selector.nvim";
          version = "2024-11-23";
          src = pkgs.fetchFromGitHub {
            owner = "linux-cultist";
            repo = "venv-selector.nvim";
            rev = "f212a424fb29949cb5e683928bdd4038bbe0062d";
            sha256 = "1m3nlxi7aghm8bnbh7vh3h47yz21lj4higywwvq1s8xr5bizb0ig";
          };
          meta.homepage = "https://github.com/linux-cultist/venv-selector.nvim/";
        })
        neotest-python
        nvim-dap-python
      ];
    };
  };
}
