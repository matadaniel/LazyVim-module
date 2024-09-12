{ pkgs, ... }:
{
  imports = [ ./typescript.nix ];

  programs.neovim = {
    extraPackages = [ pkgs.nodePackages.svelte-language-server ];

    plugins = [ (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: [ plugins.svelte ])) ];
  };
}
