self:
{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = [ pkgs.clangd ];

    plugins = [
      pkgs.vimPlugins.clangd_extensions-nvim
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: [ plugins.cpp ]))
    ];
  };
}
