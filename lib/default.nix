let
  plugins = import ../lazyvim/plugins/lib;
in
{
  inherit (plugins) buildVimPlugin buildVimPlugins;

  inherit plugins;
}
