self: finalPkgs: prevPkgs: {
  vimPlugins = prevPkgs.vimPlugins.extend (
    finalVimPlugins: prevVimPlugins:
    let
      buildVimPlugin = self.lib.plugins.buildVimPlugin self.inputs prevPkgs;
    in
    {
      nvim-treesitter = buildVimPlugin {
        pname = "nvim-treesitter";

        nvimSkipModule = [ "nvim-treesitter._meta.parsers" ];

        passthru =
          let
            inherit (builtins) attrValues filter;
            inherit (finalVimPlugins) nvim-treesitter;
            inherit (prevPkgs)
              callPackage
              lib
              runCommand
              stdenv
              symlinkJoin
              writableTmpDirAsHomeHook
              ;
            inherit (lib.attrsets) genAttrs isDerivation;
            inherit (stdenv.hostPlatform) system;

            buildGrammar = callPackage ./buildGrammar.nix { inherit nvim-treesitter; };

            builtGrammars = callPackage ./generated.nix { inherit buildGrammar; };

            allGrammars = filter isDerivation (attrValues builtGrammars);

            withGrammars = f: nvim-treesitter.overrideAttrs { passthru.grammars = f builtGrammars; };

            withAllGrammars = withGrammars (_: allGrammars);
          in
          {
            inherit
              buildGrammar
              builtGrammars
              allGrammars
              withGrammars
              withAllGrammars
              ;

            # for backward compatibility
            withPlugins = withGrammars;

            tests =
              genAttrs
                (map (x: "check-${x}") [
                  "parsers"
                  "queries"
                ])
                (
                  x:
                  runCommand "nvim-treesitter-${x}"
                    {
                      nativeBuildInputs = [
                        (self.packages.${system}.neovim.override { plugins = [ withAllGrammars ]; })
                        writableTmpDirAsHomeHook
                      ];
                      CI = true;
                    }
                    ''
                      touch $out
                      ln -s ${withAllGrammars}/CONTRIBUTING.md .

                      nvim +"lua require'nvim-treesitter'.setup { install_dir = \"${
                        symlinkJoin {
                          pname = "tree-sitter-grammars";

                          inherit (withAllGrammars) version;

                          paths = withAllGrammars.grammars;
                        }
                      }\" }" -l ${withAllGrammars}/scripts/${x}.lua
                    ''
                );
          };

        meta = {
          homepage = "https://github.com/nvim-treesitter/nvim-treesitter/tree/main";
          hydraPlatforms = [ ];
          license = prevPkgs.lib.licenses.asl20;
        };
      };

      nvim-treesitter-textobjects = buildVimPlugin {
        pname = "nvim-treesitter-textobjects";

        meta = {
          homepage = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main";
          hydraPlatforms = [ ];
          license = prevPkgs.lib.licenses.asl20;
        };
      };
    }
  );
}
