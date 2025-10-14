self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) attrValues;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.lists) optional;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.programs.lazyvim;
in
{
  options.programs.lazyvim.extras.lang.python = {
    enable = mkEnableOption "the lang.python extra";
  };

  config = mkIf cfg.extras.lang.python.enable {
    programs.lazyvim = {
      masonPackages = optionalAttrs cfg.extras.dap.core.enable {
        ${
          if pkgs.stdenv.hostPlatform.isWindows then
            "debugpy/venv/Scripts/pythonw.exe"
          else
            "debugpy/venv/bin/python"
        } =
          (pkgs.python3.withPackages (ps: [ ps.debugpy ])).interpreter;
      };
    };

    programs.neovim = {
      extraPackages = attrValues { inherit (pkgs) pyright ruff; };

      plugins =
        [
          (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: attrValues { inherit (plugins) ninja rst; }))
        ]
        ++ optional cfg.extras.dap.core.enable pkgs.vimPlugins.nvim-dap-python
        ++ optional cfg.extras.test.core.enable pkgs.vimPlugins.neotest-python;
      # TODO: ++ optional cfg.extras.editor.telescope.enable (
      #   pkgs.vimUtils.buildVimPlugin {
      #     pname = "venv-selector.nvim";
      #     version = "2024-09-15";
      #     src = pkgs.fetchFromGitHub {
      #       owner = "linux-cultist";
      #       repo = "venv-selector.nvim";
      #       rev = "e82594274bf7b54387f9a2abe65f74909ac66e97";
      #       sha256 = "0d2lzx5b1jc0zq92ziy83apxak6b2rjsgi8nz6jwyy58l96lhb03";
      #     };
      #     meta.homepage = "https://github.com/linux-cultist/venv-selector.nvim/";
      #     nvimSkipModule = [ "venv-selector.cached_venv" ];
      #   }
      # );
    };
  };
}
