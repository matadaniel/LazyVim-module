self:
{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = [ pkgs.vscode-langservers-extracted ];
  };
}
