self: system:
builtins.mapAttrs
  (name: value: {
    type = "app";
    program = value;
  })
  {
    generate = import ./generate.nix self system;
  }
