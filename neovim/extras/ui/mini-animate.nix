{ inputs, pkgs, ... }:
{
  programs.neovim = {
    plugins = [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "mini.animate";
        version = "2024-06-23";
        src = inputs.mini-animate;
      })
    ];
  };
}