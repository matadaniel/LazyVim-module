{ pkgs, ... }:
{
  programs.neovim = {
    plugins = [ pkgs.vimPlugins.yanky-nvim ];
  };
}
