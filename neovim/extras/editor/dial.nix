self:
{ pkgs, ... }:
{
  programs.neovim = {
    plugins = [ pkgs.vimPlugins.dial-nvim ];
  };
}
