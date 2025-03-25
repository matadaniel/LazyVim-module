self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.generators) mkLuaInline;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.programs.lazyvim;
in
{
  options.programs.lazyvim.extras.lang.astro = {
    enable = mkEnableOption "the lang.astro extra";
  };

  config = mkIf cfg.extras.lang.astro.enable {
    programs.lazyvim = {
      lazySpecs = {
        extras.lang.astro = [
          {
            localVars = true;

            tsservers = [
              "/tsserverlibrary.js"
              "/typescript.js"
              "/tsserver.js"
            ];
          }
          {
            ref = "neovim/nvim-lspconfig";
            opts.servers.astro.on_new_config =
              let
                tsdk = "${pkgs.vtsls}/lib/vtsls-language-server/node_modules/typescript/lib";
              in
              mkLuaInline
                # lua
                ''
                  function(new_config, new_root_dir)
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

                    local tsdk = "${tsdk}"
                    for i = 1, #tsservers do
                      local serverPath = tsdk .. tsservers[i]
                      if vim.uv.fs_stat(serverPath) then
                        new_config.init_options.typescript.serverPath = serverPath
                        new_config.init_options.typescript.tsdk = tsdk
                        return
                      end
                    end

                    LazyVim.error(
                      "Failed to find vendored Typescript module in ${tsdk}",
                      { title = "LazyVim-module" }
                    )
                    new_config.init_options.typescript.serverPath = nil
                    new_config.init_options.typescript.tsdk = nil
                  end'';
          }
        ];
      };
    };

    programs.neovim = {
      extraPackages = [ pkgs.astro-language-server ];

      plugins = [
        (pkgs.vimPlugins.nvim-treesitter.withPlugins (
          plugins: builtins.attrValues { inherit (plugins) astro css; }
        ))
      ];
    };
  };
}
