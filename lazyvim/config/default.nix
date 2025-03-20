self:
{ config, lib, ... }:
let
  inherit (lib.attrsets)
    attrByPath
    foldlAttrs
    recursiveUpdate
    setAttrByPath
    ;
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.strings) splitString;

  cfg = config.programs.lazyvim;
in
mkIf cfg.enable (
  foldlAttrs
    (
      acc: name: check:
      let
        inherit
          (builtins.foldl'
            (
              acc': elem:
              let
                extra = elem // {
                  valid = elem.enabled or true;
                  optionPath = splitString "." elem.extra ++ [ "enable" ];
                };
              in
              acc'
              // (
                if !acc'.default.valid && extra.valid then
                  { default = extra; }
                else
                  { alternatives = acc'.alternatives ++ [ extra ]; }
              )
              // {
                enabledCount =
                  acc'.enabledCount + (if extra.valid && attrByPath extra.optionPath false cfg.extras then 1 else 0);
              }
            )

            {
              alternatives = [ ];
              default = {
                name = "no \"${name}\" extra";
                valid = false;
              };
              enabledCount = 0;
            }

            check
          )
          alternatives
          default
          enabledCount
          ;
      in
      acc
      // {
        assertions = acc.assertions ++ [
          {
            assertion = enabledCount == 1;
            message = "${
              if enabledCount > 1 then "More than one" else "No"
            } \"${name}\" extra enabled. LazyVim uses ${default.name} by default. Enable ${
              self.lib.formatList lib "or" (
                lib.optional default.valid "`${default.extra}` (default)"
                ++ map (alternative: "`${alternative.extra}`") alternatives
              )
            }.";
          }
        ];

        programs.lazyvim.extras = recursiveUpdate acc.programs.lazyvim.extras (
          setAttrByPath default.optionPath (
            mkIf (builtins.all (
              alternative: !(alternative.valid && attrByPath alternative.optionPath false cfg.extras)
            ) alternatives) (mkDefault true)
          )
        );
      }
    )

    {
      assertions = [ ];

      programs.lazyvim.extras = { };
    }

    # from LazyVim/lua/lazyvim/config/init.lua
    {
      # WARN: each check MUST be a non-empty list
      picker = [
        {
          name = "snacks";
          extra = "editor.snacks_picker";
        }
        {
          name = "fzf";
          extra = "editor.fzf";
        }
        {
          name = "telescope";
          extra = "editor.telescope";
        }
      ];
      cmp = [
        {
          name = "blink.cmp";
          extra = "coding.blink";
          enabled = self.lib.hasNvimVersion config lib "nvim-0.10";
        }
        {
          name = "nvim-cmp";
          extra = "coding.nvim-cmp";
        }
      ];
      explorer = [
        {
          name = "snacks";
          extra = "editor.snacks_explorer";
        }
        {
          name = "neo-tree";
          extra = "editor.neo-tree";
        }
      ];
    }
)
