self:
{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = [ pkgs.vscode-langservers-extracted ];

    plugins = [
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: [ plugins.json5 ]))
      pkgs.vimPlugins.SchemaStore-nvim
    ];
  };
}
