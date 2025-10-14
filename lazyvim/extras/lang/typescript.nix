self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.programs.lazyvim;
in
{
  options.programs.lazyvim.extras.lang.typescript = {
    enable = mkEnableOption "the lang.typescript extra";
  };

  config =
    mkIf
      (
        let
          inherit (cfg.extras.lang) astro svelte typescript;
        in
        astro.enable || svelte.enable || typescript.enable
      )
      {
        programs.lazyvim = {
          masonPackages = optionalAttrs cfg.extras.dap.core.enable {
            "js-debug-adapter/js-debug/src/dapDebugServer.js" =
              "${pkgs.vscode-js-debug}/lib/node_modules/js-debug/dist/src/dapDebugServer.js";
          };
        };

        programs.neovim = {
          extraPackages = [ pkgs.vtsls ];
        };
      };
}
