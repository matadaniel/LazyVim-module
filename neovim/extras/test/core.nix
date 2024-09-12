{ pkgs, ... }:
{
  programs.neovim = {
    plugins = builtins.attrValues { inherit (pkgs.vimPlugins) neotest nvim-nio; };
  };
}
