self:
{ pkgs, ... }:
{
  imports = [ ./typescript.nix ];

  programs.neovim = {
    extraPackages = [ pkgs.nodePackages."@astrojs/language-server" ];

    plugins = [ (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: [ plugins.astro ])) ];
  };

  xdg.configFile."nvim/lua/plugins/astro.lua".text = # lua
    ''
      local tsservers = {
      	"/tsserverlibrary.js",
      	"/typescript.js",
      	"/tsserver.js",
      }

      return {
      	{
      		"neovim/nvim-lspconfig",
      		opts = {
      			servers = {
      				astro = {
      					on_new_config = function(new_config, new_root_dir)
      						if new_root_dir then
      							local tsdk = new_root_dir .. "/node_modules/typescript/lib"
      							for i = 1, #tsservers do
      								local serverPath = tsdk .. tsservers[i]
      								if vim.uv.fs_stat(serverPath) then
      									new_config.init_options.typescript.serverPath = serverPath
      									new_config.init_options.typescript.tsdk = tsdk
      									return
      								end
      							end
      						end

      						local tsdk = "${pkgs.vtsls}/lib/node_modules/@vtsls/language-server/node_modules/typescript/lib"
      						for i = 1, #tsservers do
      							local serverPath = tsdk .. tsservers[i]
      							if vim.uv.fs_stat(serverPath) then
      								new_config.init_options.typescript.serverPath = serverPath
      								new_config.init_options.typescript.tsdk = tsdk
      								return
      							end
      						end

      						LazyVim.error(
      							"Failed to find vendored Typescript module in ${pkgs.vtsls}/lib/node_modules/@vtsls/language-server",
      							{ title = "LazyVim-module" }
      						)
      						new_config.init_options.typescript.serverPath = nil
      						new_config.init_options.typescript.tsdk = nil
      					end,
      				},
      			},
      		},
      	},
      }
    '';
}
