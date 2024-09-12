{ inputs, pkgs, ... }:
{
  programs.neovim = {
    plugins = [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "mini.surround";
        version = "2024-06-23";
        src = inputs.mini-surround;
      })
    ];
  };
}
