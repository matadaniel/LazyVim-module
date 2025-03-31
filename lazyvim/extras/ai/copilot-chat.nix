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
  options.programs.lazyvim.extras.ai.copilot-chat = {
    enable = mkEnableOption "the ai.copilot-chat extra";
  };

  config = mkIf cfg.extras.ai.copilot-chat.enable {
    programs.neovim = {
      plugins = [ pkgs.vimPlugins.CopilotChat-nvim ];
    };
  };
}
