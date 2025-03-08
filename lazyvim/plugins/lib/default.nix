let
  lib = {
    pluginAttrs =
      inputs:
      {
        pname,
        src ? inputs.${pname},
        version ?
          let
            inherit (src) lastModifiedDate;
          in
          "${builtins.substring 0 4 lastModifiedDate}-${builtins.substring 4 2 lastModifiedDate}-${
            builtins.substring 6 2 lastModifiedDate
          }",
        ...
      }@attrs:
      { inherit src version; } // attrs;

    buildVimPlugin =
      inputs: pkgs: attrsOrPname:
      pkgs.vimUtils.buildVimPlugin (
        lib.pluginAttrs inputs (
          if builtins.isString attrsOrPname then { pname = attrsOrPname; } else attrsOrPname
        )
      );

    buildVimPlugins =
      inputs: pkgs: list:
      let
        inherit (pkgs.vimUtils) buildVimPlugin;

        pluginAttrs = lib.pluginAttrs inputs;
      in
      map (
        attrsOrPname:
        buildVimPlugin (
          pluginAttrs (if builtins.isString attrsOrPname then { pname = attrsOrPname; } else attrsOrPname)
        )
      ) list;
  };
in
lib
