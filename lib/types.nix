{ lib }:
let
  inherit (lib.types) either;

  set = {
    nested =
      composedType: elemType:
      let
        type = composedType (either elemType type);
      in
      type;
  };
in
set
