self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.lists) optional optionals;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.programs.lazyvim;
in
{
  options.programs.lazyvim.extras.ai.copilot = {
    enable = mkEnableOption "the ai.copilot extra";
  };

  config = mkIf cfg.extras.ai.copilot.enable {
    programs.lazyvim = {
      lazySpecs = {
        extras.ai.copilot = [
          {
            ref = "zbirenbaum/copilot.lua";
            opts.server = {
              type = "binary";
              custom_server_filepath = getExe pkgs.copilot-language-server-fhs;
            };
          }
        ];
      };
    };

    programs.neovim = {
      plugins =
        [ pkgs.vimPlugins.copilot-lua ]
        ++ optionals cfg.ai_cmp (
          optional cfg.extras.coding.blink.enable pkgs.vimPlugins.blink-cmp-copilot
          # TODO: ++ optional cfg.extras.coding.nvim-cmp.enable pkgs.vimPlugins.copilot-cmp
        );
    };
  };
}
