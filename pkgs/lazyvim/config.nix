{
  wayland.windowManager.hyprland.enable = true;
  programs = {
    fish.enable = true;
    wofi.enable = true;
    rofi.enable = true;
    neovim.finalPackage.passthru.packpathDirs.myNeovimPackages.start = [ ];
    lazyvim = {
      enable = true;
      extras = {
        coding = {
          mini-surround.enable = true;
          yanky.enable = true;
        };

        dap = {
          core.enable = true;
        };

        editor = {
          dial.enable = true;
          inc-rename.enable = true;
        };

        formatting = {
          prettier.enable = true;
        };

        lang = {
          astro.enable = true;
          json.enable = true;
          markdown.enable = true;
          nix.enable = true;
          prisma.enable = true;
          svelte.enable = true;
          tailwind.enable = true;
          typescript.enable = true;
        };

        linting = {
          eslint.enable = true;
        };

        test = {
          core.enable = true;
        };

        ui = {
          mini-animate.enable = true;
        };

        util = {
          dot.enable = true;

          mini-hipatterns.enable = true;
        };
      };
      plugins = [ ];
      pluginsToDisable = [ ];
      pluginsFile = null;
    };
  };
}
