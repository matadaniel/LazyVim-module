{
  description = "Home Manager module for LazyVim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default";
  };

  outputs =
    {
      nixpkgs,
      self,
      systems,
      ...
    }:
    {
      homeManagerModules = {
        default = self.homeManagerModules.lazyvim;
        lazyvim = import ./lazyvim self;
      };

      lib = import ./lib { inherit (nixpkgs) lib; };

      packages = nixpkgs.lib.genAttrs (import systems) (
        system:
        let
          inherit (import nixpkgs { inherit system; }) callPackage;
        in
        {
          astro-ts-plugin = callPackage ./pkgs/astro-ts-plugin { };
          markdown-toc = callPackage ./pkgs/markdown-toc { };
          typescript-svelte-plugin = callPackage ./pkgs/typescript-svelte-plugin { };
        }
      );
    };
}
