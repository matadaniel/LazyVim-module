# LazyVim-module

[Flake](https://wiki.nixos.org/wiki/Flakes) with a
[Home Manager](https://nix-community.github.io/home-manager/) module for [LazyVim](https://lazyvim.github.io/).

## 💡 Motivation

One of my biggest apprehensions to installing NixOS was
the trouble it would take to use my favorite setup for Neovim: LazyVim.
For some reason I installed it anyway and struggled through the steep learning curve.
LazyVim-module configures Neovim to work with LazyVim and its extras.
It will leave you free to struggle through the configuration of other programs.

## 🚀 Quick Start

> [!IMPORTANT]
> LazyVim-module requires packages that are not available in nixos-24.05.

Simply import the module and enable lazyvim!

Example `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # add LazyVim-module
    lazyvim = {
      url = "github:matadaniel/LazyVim-module";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    {
      homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = [ ./home-manager/home.nix ];
      };
    };
}
```

Example `home-manager/home.nix`:

```nix
{ inputs, ... }:
{
  imports = [ inputs.lazyvim.homeManagerModules.default ];

  programs.lazyvim = {
    enable = true;
  };
}
```

### Requirements

- terminal emulator that supports true color and undercurl

#### Optional

- [lazygit](https://github.com/jesseduffield/lazygit)
- [Nerd Font](https://nerdfonts.com/) (required to display some icons)

## 📖 Usage

Enable extras

```nix
{
  programs.lazyvim = {
    extras = {
      coding = {
        yanky.enable = true;
      };

      editor = {
        dial.enable = true;

        inc-rename.enable = true;
      };

      lang = {
        nix.enable = true;
      };

      test = {
        core.enable = true;
      };

      util = {
        dot.enable = true;

        mini-hipatterns.enable = true;
      };
    };
  };
}
```

Bring your own plugins

```nix
{ pkgs, ... }:
{
  programs.lazyvim = {
    plugins = [ pkgs.vimPlugins.undotree ];
    pluginsFile."editor.lua".source = ./editor.lua;
  };
}
```

```lua
-- editor.lua

return {
	{
		"mbbill/undotree",
		keys = { { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Toggle undotree" } },
		init = function()
			vim.g.undotree_WindowLayout = 4
		end,
	},
}
```

## 🤝 Contributing

If there is an extra that you always use that is not currently [supported](lazyvim/extras),
please open an issue if there is not one open already!
