self:
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.options) mkEnableOption mkOption;
in
{
  # Mimic configuration of Home Manager modules used by LazyVim-module.
  options = {
    xdg = {
      configFile = mkOption {
        type = lib.types.str;
      };
    };
    programs = {
      neovim = {
        enable = mkEnableOption "neovim";
        plugins = mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "Plugins";
        };
        extraLuaConfig = mkOption {
          type = lib.types.str;
          default = "";
          description = "extra lua config";
        };
        extraPackages = mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "extra packages";
        };
      };
    };
  };
}
