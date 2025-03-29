{lib}: let
  inherit (lib.lists) init last;
  inherit (lib.strings) getVersion optionalString versionAtLeast;

  set = {
    formatList = coordinator: list: let
      len = builtins.length list;
    in
      optionalString (len > 0) (
        let
          first = builtins.head list;
        in
          if len == 1
          then first
          else if len == 2
          then "${first} ${coordinator} ${builtins.elemAt list 1}"
          else builtins.concatStringsSep ", " (init list) + ", ${coordinator} ${last list}"
      );

    hasNvimVersion = config: nvimVersion: let
      neovimPkgVersion = getVersion config.programs.neovim.package;
      v1 =
        if neovimPkgVersion == "nightly"
        then getVersion "nvim-0.11"
        else neovimPkgVersion;
      v2 = getVersion nvimVersion;
    in
      versionAtLeast v1 v2;
  };
in
  set
