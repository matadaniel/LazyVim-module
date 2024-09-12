{ inputs, pkgs, ... }:
{
  programs.neovim = {
    extraPackages = [ pkgs.tailwindcss-language-server ];

    plugins = [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "tailwindcss-colorizer-cmp.nvim";
        version = "2024-06-23";
        src = inputs.tailwindcss-colorizer-cmp-nvim;
      })
    ];
  };
}
