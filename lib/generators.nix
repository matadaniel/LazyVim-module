{lib}: let
  inherit (builtins) foldl' stringLength substring;
  inherit (lib.attrsets) foldlAttrs;
  inherit (lib.generators) toLua;
  inherit (lib.strings) optionalString;

  set = {
    toLazySpecs = {indent ? "  "}: specs: let
      inherit
        (
          foldl'
          (
            acc: spec:
              acc
              // (
                if spec.localVars or false
                then {
                  localVars =
                    foldlAttrs (
                      acc': name: value:
                        optionalString (name != "localVars") ''
                          ${acc'}local ${toLua {asBindings = true;} {${name} = value;}}
                        ''
                    )
                    acc.localVars
                    spec;
                }
                else {
                  lazySpecs = ''
                    ${acc.lazySpecs}
                    ${indent}{
                    ${
                      optionalString (spec ? ref) ''
                        ${indent}${indent}"${spec.ref}",
                      ''
                    }${
                      let
                        luaSpec = toLua {inherit indent;} (removeAttrs spec ["ref"]);
                        trimLen = stringLength ''
                          ${indent}{
                        '';
                      in "${indent}${substring trimLen (stringLength luaSpec - (trimLen * 2)) luaSpec}"
                    }
                    ${indent}},
                  '';
                }
              )
          )
          {
            localVars = "";
            lazySpecs = "";
          }
          specs
        )
        localVars
        lazySpecs
        ;
    in "${localVars}return {${lazySpecs}}";
  };
in
  set
