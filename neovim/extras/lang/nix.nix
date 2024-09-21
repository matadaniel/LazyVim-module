self:
{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = builtins.attrValues { inherit (pkgs) nil nixfmt-rfc-style; };

    plugins = [ (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: [ plugins.nix ])) ];
  };
}
