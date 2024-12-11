{
  description = "Home Manager module for LazyVim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default-linux";

    tailwindcss-colorizer-cmp-nvim.url = "github:roobert/tailwindcss-colorizer-cmp.nvim";
    tailwindcss-colorizer-cmp-nvim.flake = false;
  };

  outputs =
    {
      nixpkgs,
      self,
      systems,
      ...
    }@inputs:
    {
      homeManagerModules = {
        default = self.homeManagerModules.lazyvim;
        lazyvim = import ./lazyvim self;
      };

      nixosModules = {
        default = self.nixosModules.lazyvim;
        lazyvim = import ./pkgs/lazyvim/module.nix self;
      };

      packages = nixpkgs.lib.genAttrs (import systems) (
        system:
        let
          inherit (import nixpkgs { inherit system; }) callPackage;
        in
        rec {
          astro-ts-plugin = callPackage ./pkgs/astro-ts-plugin { };
          markdown-toc = callPackage ./pkgs/markdown-toc { };
          typescript-svelte-plugin = callPackage ./pkgs/typescript-svelte-plugin { };
          lazyvim = callPackage ./pkgs/lazyvim {
            inherit self inputs;
          };
          default = lazyvim;
        }
      );
    };
}
