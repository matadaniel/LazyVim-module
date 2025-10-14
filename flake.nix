{
  description = "Home Manager module for LazyVim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nvim-treesitter = {
      flake = false;
      url = "github:nvim-treesitter/nvim-treesitter/main";
    };

    nvim-treesitter-textobjects = {
      flake = false;
      url = "github:nvim-treesitter/nvim-treesitter-textobjects/main";
    };

    systems.url = "github:nix-systems/default-linux";
  };

  outputs =
    {
      nixpkgs,
      self,
      systems,
      ...
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      apps = eachSystem (system: import ./apps self system);

      homeManagerModules = {
        default = self.homeManagerModules.lazyvim;
        lazyvim = import ./lazyvim self;
      };

      lib = import ./lib { inherit (nixpkgs) lib; };

      overlays = import ./overlays self;

      packages = eachSystem (
        system:
        let
          inherit (import nixpkgs { inherit system; })
            callPackage
            lib
            neovim-unwrapped
            wrapNeovimUnstable
            ;

          wrapNeovim = neovim-unwrapped: lib.makeOverridable (wrapNeovimUnstable neovim-unwrapped);
        in
        {
          inherit wrapNeovim;

          astro-ts-plugin = callPackage ./pkgs/astro-ts-plugin { };
          markdown-toc = callPackage ./pkgs/markdown-toc { };
          neovim = wrapNeovim neovim-unwrapped {
            autowrapRuntimeDeps = false;
            withPython3 = false;
            waylandSupport = false;
            withRuby = false;
            wrapRc = false;
          };
          typescript-svelte-plugin = callPackage ./pkgs/typescript-svelte-plugin { };
        }
      );
    };
}
