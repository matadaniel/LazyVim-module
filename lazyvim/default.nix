self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.attrsets) mapAttrs' nameValuePair;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.trivial) warnIf;
  inherit (lib.types)
    anything
    attrsOf
    listOf
    pathInStore
    str
    submodule
    ;
  inherit (pkgs) linkFarm symlinkJoin;
  inherit (self.lib.generators) toLazySpecs;
  inherit (self.lib.types) nested;

  cfg = config.programs.lazyvim;

  pathsAndSpecs =
    path: specs:
    if builtins.isAttrs specs then
      builtins.concatMap (name: pathsAndSpecs (path ++ [ name ]) specs.${name}) (builtins.attrNames specs)
    else
      [ { inherit path specs; } ];

  pathsWithSpecs = pathsAndSpecs [ ] cfg.lazySpecs;

  specsPluginName = "LazyVim-module-specs";
in
{
  imports = map (module: import module self) [
    ./config

    ./extras/ai/copilot-chat.nix
    ./extras/ai/copilot.nix

    ./extras/coding/blink.nix
    ./extras/coding/mini-snippets.nix
    ./extras/coding/mini-surround.nix
    ./extras/coding/yanky.nix

    ./extras/dap/core.nix

    ./extras/editor/dial.nix
    ./extras/editor/fzf.nix
    ./extras/editor/inc-rename.nix
    ./extras/editor/leap.nix
    ./extras/editor/snacks_explorer.nix
    ./extras/editor/snacks_picker.nix

    ./extras/formatting/prettier.nix

    ./extras/lang/astro.nix
    ./extras/lang/go.nix
    ./extras/lang/json.nix
    ./extras/lang/markdown.nix
    ./extras/lang/nix.nix
    ./extras/lang/prisma.nix
    ./extras/lang/python.nix
    ./extras/lang/rust.nix
    ./extras/lang/svelte.nix
    ./extras/lang/tailwind.nix
    ./extras/lang/typescript.nix
    ./extras/lang/zig.nix

    ./extras/linting/eslint.nix

    ./extras/test/core.nix

    ./extras/ui/mini-animate.nix

    ./extras/util/dot.nix
    ./extras/util/mini-hipatterns.nix

    ./plugins
  ];

  options.programs.lazyvim = {
    enable = mkEnableOption "lazyvim";

    pluginsToDisable = mkOption {
      default = [ ];
      description = ''
        List of plugins to remove.
      '';
      example = ''
        [
          {
            lazyName = "folke/trouble.nvim";
            nixName = "trouble-nvim";
          }
        ]
      '';
      type = listOf (submodule {
        options = {
          lazyName = mkOption { type = str; };
          nixName = mkOption { type = str; };
        };
      });
    };

    lazySpecs = mkOption {
      default = { };
      internal = true;
      type = nested attrsOf (listOf (attrsOf anything));
    };

    ai_cmp = mkEnableOption "installation of packages for vim.g.ai_cmp" // {
      default = true;
    };

    masonPackages = mkOption {
      default = { };
      description = ''
        Attribute set of store paths to link into {file}`$MASON/packages/`.
      '';
      example = ''
        {
          "js-debug-adapter/js-debug/src/dapDebugServer.js" =
            "''${pkgs.vscode-js-debug}/lib/node_modules/js-debug/dist/src/dapDebugServer.js";
        }
      '';
      type = attrsOf pathInStore;
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ self.overlays.nvim-treesitter-main ];

    programs.neovim = {
      enable = true;

      extraLuaConfig = ''
        ${
          lib.optionalString (cfg.masonPackages != { }) ''
            vim.env.MASON = "${
              linkFarm "mason" (mapAttrs' (name: path: nameValuePair "packages/${name}" path) cfg.masonPackages)
            }"

          ''
        }require("lazy").setup({
        	dev = { path = vim.api.nvim_list_runtime_paths()[1] .. "/pack/myNeovimPackages/start", patterns = { "" } },
        	spec = {
        		-- add LazyVim and import its plugins
        		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },${
            lib.optionalString (cfg.lazySpecs != { }) ''

              		{ dir = "${
                  pkgs.vimUtils.buildVimPlugin {
                    name = specsPluginName;
                    src = pkgs.buildEnv {
                      name = specsPluginName;
                      paths = map (
                        { path, specs }:
                        pkgs.writeTextDir "${builtins.concatStringsSep "/" path}.lua" (toLazySpecs { } specs)
                      ) pathsWithSpecs;
                      extraPrefix = "/lua/${specsPluginName}/plugins";
                    };
                  }
                }" },''
          }
        		{ "jay-babu/mason-nvim-dap.nvim", enabled = false },
        		{ "mason-org/mason-lspconfig.nvim", enabled = false },
        		{ "mason-org/mason.nvim", enabled = false },${
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
                  else if name == "enable" && v && options.extra or true then
                    [ path ]
                  else
                    [ ]
                ) (builtins.attrNames options);

              enabledExtras = enabledOptions "extras" cfg.extras;
            in
            lib.optionalString (cfg.pluginsToDisable != [ ] || enabledExtras != [ ]) "\n\t\t"
            + builtins.concatStringsSep "\n\t\t" (
              map (plugin: "{ \"${plugin.lazyName}\", enabled = false },") cfg.pluginsToDisable
              ++ map (extra: "{ import = \"lazyvim.plugins.${extra}\" },") enabledExtras
              ++ map (
                { path, ... }: "{ import = \"${specsPluginName}.plugins.${builtins.concatStringsSep "." path}\" },"
              ) pathsWithSpecs
            )
          }
        		-- import/override with your plugins
        		{ import = "plugins" },
        		{
        			"nvim-treesitter/nvim-treesitter",
        			opts = {
        				install_dir = "${
              symlinkJoin {
                pname = "tree-sitter-grammars";

                inherit (pkgs.vimPlugins.nvim-treesitter) version;

                paths = map ({ key, requires }: key) (
                  let
                    wrapGrammars =
                      grammars:
                      map (grammar: {
                        key = "${grammar}";
                        inherit (grammar) requires;
                      }) grammars;
                  in
                  builtins.genericClosure {
                    startSet = wrapGrammars (
                      builtins.filter
                        (
                          grammar:
                          let
                            inherit (grammar) pname tier;

                            unsupported = tier == 4;
                          in
                          warnIf unsupported ''
                            `nvim-treesitter` has marked `${pname}` as unsupported.
                            `${pname}` will not be included in the
                            `tree-sitter-grammars` derivation used by `LazyVim-module`.
                          '' (!unsupported)
                        )
                        (
                          builtins.concatMap (
                            plugin: plugin.grammars or [ ]
                          ) config.programs.neovim.finalPackage.passthru.packpathDirs.myNeovimPackages.start
                        )
                    );
                    operator = { key, requires }: wrapGrammars requires;
                  }
                );
              }
            }"
        			},
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
              builtins.concatStringsSep "\n\t\t\t\t" (
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

      plugins = builtins.attrValues (
        removeAttrs {
          inherit (pkgs.vimPlugins)
            bufferline-nvim
            conform-nvim
            flash-nvim
            friendly-snippets
            gitsigns-nvim
            grug-far-nvim
            lazy-nvim
            lazydev-nvim
            LazyVim
            lualine-nvim
            mini-ai
            mini-icons
            mini-pairs
            neo-tree-nvim
            noice-nvim
            nui-nvim
            nvim-lint
            nvim-lspconfig
            nvim-treesitter-textobjects
            nvim-ts-autotag
            persistence-nvim
            plenary-nvim
            snacks-nvim
            todo-comments-nvim
            tokyonight-nvim
            trouble-nvim
            ts-comments-nvim
            which-key-nvim
            ;
          # HACK:
          # LazyVim sets catppuccin/nvim's name to catppuccin.
          # lazy.nvim expects the name to match the path.
          # lib.getName is used to link each plugin into vim-pack-dir.
          # lib.getName returns the pname attribute if
          # the argument is not a string and the pname attribute is set.
          #
          # programs.neovim -> pkgs.wrapNeovimUnstable ->
          # neovimUtils.packDir -> vimUtils.packDir -> vimFarm ->
          # linkFarm name [ { name = "${prefix}/${lib.getName drv}"; path = drv; } ]
          catppuccin-nvim = pkgs.vimPlugins.catppuccin-nvim.overrideAttrs (oldAttrs: {
            pname = "catppuccin";
          });
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
        } (map (plugin: plugin.nixName) cfg.pluginsToDisable)
      );
    };
  };
}
