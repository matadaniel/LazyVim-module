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
  inherit (self.lib.generators) toLazySpecs;

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
        "example.lua".source = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/LazyVim/starter/refs/heads/main/lua/plugins/example.lua";
          hash = "sha256-Y8q4s3oxnaZAsHO21lSxGVJ3bqyMtV2KasAOXxcTZro=";
        };
      };
      defaultText = literalExpression ''
        {
          "example.lua".source = pkgs.fetchurl {
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

    pluginsSpecs = mkOption {
      default = { };
      description = "Attribute set of specs to link into {file}`$XDG_CONFIG_HOME/nvim/lua/plugins/`.";
      # TODO: port rest of editor.lua from README
      example = ''
        {
          "editor.lua" = [
            {
              ref = "mbbill/undotree";
              keys = [
                [
                  "<leader>uu"
                  "<cmd>UndotreeToggle<cr>"
                ]
              ];
            }
          ];
        }
      '';
      type = attrsOf (listOf (attrsOf anything));
    };
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      inherit (cfg) plugins;
    };

    xdg.configFile =
      mapAttrs' (
        name: specs: nameValuePair ("nvim/lua/plugins/" + name) { text = toLazySpecs { } specs; }
      ) cfg.pluginsSpecs
      // mapAttrs' (name: file: nameValuePair ("nvim/lua/plugins/" + name) file) cfg.pluginsFile;
  };
}
