self:
{ inputs, pkgs, ... }:
{
  programs.neovim = {
    plugins = [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "mini.hipatterns";
        version = "2024-06-23";
        src = inputs.mini-hipatterns;
      })
    ];
  };
}
