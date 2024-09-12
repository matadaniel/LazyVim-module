{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = [
      # js-debug-adapter for nvim-dap
      # pkgs.vscode-js-debug
      pkgs.vtsls
    ];
  };
}
