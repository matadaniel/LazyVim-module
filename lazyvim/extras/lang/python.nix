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
        ruff
        python312Packages.debugpy
      ];

      plugins = with pkgs.vimPlugins; [
        (nvim-treesitter.withPlugins (
          plugins: builtins.attrValues {
            inherit (plugins)
              ninja
              rst;
          }
        ))
        (pkgs.vimUtils.buildVimPlugin {
          pname = "venv-selector.nvim";
          version = "2024-09-15";
          src = pkgs.fetchFromGitHub {
            owner = "linux-cultist";
            repo = "venv-selector.nvim";
            rev = "e82594274bf7b54387f9a2abe65f74909ac66e97";
            sha256 = "0d2lzx5b1jc0zq92ziy83apxak6b2rjsgi8nz6jwyy58l96lhb03";
          };
          meta.homepage = "https://github.com/linux-cultist/venv-selector.nvim/";
          nvimSkipModule = [
            "venv-selector.cached_venv"
          ];
        })
        neotest-python
        nvim-dap-python
      ];
    };
  };
}
