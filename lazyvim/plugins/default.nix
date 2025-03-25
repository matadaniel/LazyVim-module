self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.attrsets) mapAttrs' nameValuePair;
  inherit (lib.modules) mkIf;
  inherit (lib.options) literalExpression mkOption;
  inherit (lib.types)
    anything
    attrsOf
    listOf
    package
    ;

  cfg = config.programs.lazyvim;
in
{
  options.programs.lazyvim = {
    plugins = mkOption {
      default = [ ];
      description = ''
        List of vim plugins to install.
      '';
      example = ''
        [ pkgs.vimPlugins.undotree ]
      '';
      type = listOf package;
    };

    pluginsFile = mkOption {
      default = {
        "nvim/lua/plugins/example.lua".source = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/LazyVim/starter/refs/heads/main/lua/plugins/example.lua";
          hash = "sha256-Y8q4s3oxnaZAsHO21lSxGVJ3bqyMtV2KasAOXxcTZro=";
        };
      };
      defaultText = literalExpression ''
        {
          "nvim/lua/plugins/example.lua".source = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/LazyVim/starter/refs/heads/main/lua/plugins/example.lua";
            hash = "sha256-Y8q4s3oxnaZAsHO21lSxGVJ3bqyMtV2KasAOXxcTZro=";
          };
        }
      '';
      description = ''
        Attribute set of files to link into {file}`$XDG_CONFIG_HOME/nvim/lua/plugins/`.

        Downloads the example from the LazyVim Starter if it is not set.
      '';
      example = ''
        {
          "editor.lua".source = ./editor.lua;
        }
      '';
      # HM does not seem to export the `fileType` type.
      # xdg.configFile should throw an error if the attribute set is invalid.
      type = attrsOf anything;
    };
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      plugins = cfg.plugins;
    };

    xdg.configFile = mapAttrs' (
      name: file: nameValuePair ("nvim/lua/plugins/" + name) file
    ) cfg.pluginsFile;
  };
}
