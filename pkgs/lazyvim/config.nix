{
  wayland.windowManager.hyprland.enable = true;
  programs = {
    fish.enable = true;
    wofi.enable = true;
    rofi.enable = true;
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
          nix.enable = true;
          astro.enable = false;
          svelte.enable = false;
          tailwind.enable = false;
          prisma.enable = false;
          markdown.enable = false;
          json.enable = false;
          typescript.enable = false;
        };

        linting = {
          eslint.enable = true;
        };

        test = {
          core.enable = true;
        };

        util = {
          dot.enable = true;

          mini-hipatterns.enable = true;
        };

        ui = {
          mini-animate.enable = false;
        };
      };
      plugins = [ ];
      pluginsToDisable = [
        {
          lazyName = "plugins";
          nixName = "plugins";
        }
      ];
      pluginsFile = null;
    };
  };
}
