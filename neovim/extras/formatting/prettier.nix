{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = [ pkgs.nodePackages.prettier ];
  };
}
