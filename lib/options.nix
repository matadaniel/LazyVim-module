{lib}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) bool;

  set = {
    mkNotExtraOption = mkOption {
      default = false;
      internal = true;
      type = bool;
      visible = false;
    };
  };
in
  set
