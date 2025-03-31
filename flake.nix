{
  description = "Home Manager module for LazyVim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default-linux";
  };

  outputs =
    {
      nixpkgs,
      self,
      systems,
      ...
    }:
    {
      homeManagerModules = lib.mapAttrs (
        name:
        lib.warn "Obsolete Flake attribute `lazyvim.homeManagerModules.${name}' is used. It was renamed to `lazyvim.homeModules.${name}`'."
      ) self.homeModules;

      homeModules = {
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
