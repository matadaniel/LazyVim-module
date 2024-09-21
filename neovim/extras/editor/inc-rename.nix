self:
{ pkgs, ... }:
{
  programs.neovim = {
    plugins = [ pkgs.vimPlugins.inc-rename-nvim ];
  };
}
