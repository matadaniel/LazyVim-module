{ inputs, pkgs, ... }:
{
  programs.neovim = {
    extraPackages = builtins.attrValues { inherit (pkgs) markdown-toc markdownlint-cli2 marksman; };

    plugins = [
      pkgs.vimPlugins.markdown-preview-nvim
      (pkgs.vimUtils.buildVimPlugin {
        pname = "markdown.nvim";
        version = "2024-08-09";
        src = inputs.markdown-nvim;
      })
    ];
  };
}
