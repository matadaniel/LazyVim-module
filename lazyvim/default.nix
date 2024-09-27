self:
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.programs.lazyvim;
in
{
  imports = map (module: import module self) [
    ./extras/coding/mini-surround.nix
    ./extras/coding/yanky.nix

    ./extras/editor/dial.nix
    ./extras/editor/inc-rename.nix

    ./extras/formatting/prettier.nix

    ./extras/lang/astro.nix
    ./extras/lang/json.nix
    ./extras/lang/markdown.nix
    ./extras/lang/nix.nix
    ./extras/lang/svelte.nix
    ./extras/lang/tailwind.nix
    ./extras/lang/typescript.nix

    ./extras/linting/eslint.nix

    ./extras/test/core.nix

    ./extras/ui/mini-animate.nix

    ./extras/util/dot.nix
    ./extras/util/mini-hipatterns.nix
  ];

  options.programs.lazyvim = {
    enable = mkEnableOption "lazyvim";
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;

      extraLuaConfig = ''
        vim.env.MASON = "${
          pkgs.linkFarm "mason" (
            map
              (
                { name, path }:
                {
                  name = "packages/" + name;
                  path = path + "/lib";
                }
              )
              [
                {
                  name = "astro-language-server";
                  path = pkgs."@astrojs/ts-plugin";
                }
                {
                  name = "svelte-language-server";
                  path = pkgs.typescript-svelte-plugin;
                }
              ]
          )
        }"

        require("lazy").setup({
        	dev = { path = vim.api.nvim_list_runtime_paths()[1] .. "/pack/myNeovimPackages/start", patterns = { "." } },
        	spec = {
        		-- add LazyVim and import its plugins
        		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
        		{ "williamboman/mason-lspconfig.nvim", enabled = false },
        		{ "williamboman/mason.nvim", enabled = false },
            ${
              builtins.concatStringsSep "\n    " (
                map (extra: "{ import = \"lazyvim.plugins.${extra}\" },") (
                  let
                    enabledOptions =
                      path: options:
                      builtins.concatMap (
                        name:
                        let
                          v = options.${name};
                        in
                        if builtins.isAttrs v then
                          enabledOptions (path + "." + name) v
                        else if name == "enable" && v then
                          [ path ]
                        else
                          [ ]
                      ) (builtins.attrNames options);
                  in
                  enabledOptions "extras" cfg.extras
                )
              )
            }
        		-- import/override with your plugins
        		{ import = "plugins" },
        		{
        			"nvim-treesitter/nvim-treesitter",
        			opts = function(_, opts)
        				opts.ensure_installed = {}
        			end,
        		},
        	},
        	defaults = {
        		-- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
        		-- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
        		lazy = false,
        		-- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
        		-- have outdated releases, which may break your Neovim install.
        		version = false, -- always use the latest git commit
        		-- version = "*", -- try installing the latest stable version for plugins that support semver
        	},
        	install = { colorscheme = { "tokyonight", "habamax" } },
        	checker = { enabled = true }, -- automatically check for plugin updates
        	performance = {
        		rtp = {
        			-- disable some rtp plugins
        			disabled_plugins = {
        				"gzip",
        				-- "matchit",
        				-- "matchparen",
        				-- "netrwPlugin",
        				"tarPlugin",
        				"tohtml",
        				"tutor",
        				"zipPlugin",
        			},
        			paths = {
                ${
                  let
                    wrapPlugins =
                      plugins:
                      map (plugin: {
                        key = plugin.outPath;
                        deps = plugin.dependencies or [ ];
                      }) plugins;
                  in
                  builtins.concatStringsSep "\n        " (
                    map ({ key, deps }: "\"${key}\",") (
                      builtins.genericClosure {
                        startSet = wrapPlugins (
                          builtins.concatMap (
                            plugin: plugin.dependencies or [ ]
                          ) config.programs.neovim.finalPackage.passthru.packpathDirs.myNeovimPackages.start
                        );
                        operator = { key, deps }: wrapPlugins deps;
                      }
                    )
                  )
                }
        			},
        		},
        	},
        })
      '';

      extraPackages = builtins.attrValues { inherit (pkgs) lua-language-server shfmt stylua; };

      plugins =
        builtins.attrValues {
          inherit (pkgs.vimPlugins)
            bufferline-nvim
            catppuccin-nvim
            cmp-buffer
            cmp-nvim-lsp
            cmp-path
            conform-nvim
            dashboard-nvim
            dressing-nvim
            flash-nvim
            friendly-snippets
            gitsigns-nvim
            grug-far-nvim
            indent-blankline-nvim
            lazy-nvim
            lazydev-nvim
            LazyVim
            lualine-nvim
            luvit-meta
            neo-tree-nvim
            noice-nvim
            nui-nvim
            nvim-cmp
            nvim-lint
            nvim-lspconfig
            nvim-notify
            nvim-snippets
            nvim-treesitter-textobjects
            nvim-ts-autotag
            persistence-nvim
            plenary-nvim
            telescope-nvim
            todo-comments-nvim
            tokyonight-nvim
            trouble-nvim
            which-key-nvim
            ;
          nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (
            plugins:
            builtins.attrValues {
              inherit (plugins)
                bash
                c
                diff
                html
                javascript
                jsdoc
                json
                jsonc
                lua
                luadoc
                luap
                markdown
                markdown_inline
                printf
                python
                query
                regex
                toml
                tsx
                typescript
                vim
                vimdoc
                xml
                yaml
                ;
            }
          );
        }
        ++ builtins.attrValues (
          builtins.mapAttrs
            (
              input: pname:
              pkgs.vimUtils.buildVimPlugin {
                inherit pname;
                version = "2024-08-09";
                src = inputs.${input};
              }
            )
            {
              mini-ai = "mini.ai";
              mini-icons = "mini.icons";
              mini-pairs = "mini.pairs";
              ts-comments-nvim = "ts-comments.nvim";
            }
        );
    };
  };
}
