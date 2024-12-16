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
  options = {
    xdg = {
      configFile = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              enable = mkEnableOption "Whether this file should be generated.";
              source = mkOption {
                type = lib.types.path;
                default = null;
                description = "Path of the source file or directory.";
              };
              text = mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Text content of the file.";
              };
            };
          }
        );
        default = { };
        description = "Configuration files managed by xdg.";
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
