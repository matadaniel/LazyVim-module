{
  lib,
  nodejs,
  nvim-treesitter,
  stdenv,
  tree-sitter,
  writableTmpDirAsHomeHook,
}:

{
  name,
  src ? null,
  revision,
  build ? src != null,
  generate_from_json ? true,
  location ? null,
  generate ? false,
  abi_version ? "15",
  requires ? [ ],
  tier,
  ...
}@args:

stdenv.mkDerivation (
  {
    pname = "tree-sitter-${builtins.replaceStrings [ "_" ] [ "-" ] name}";

    inherit src;

    version = revision;

    nativeBuildInputs =
      lib.optionals build [
        tree-sitter
        writableTmpDirAsHomeHook
      ]
      ++ lib.optional (!generate_from_json) nodejs;

    dontUnpack = !build;

    configurePhase =
      lib.optionalString (location != null) ''
        cd ${location}
      ''
      + lib.optionalString generate ''
        tree-sitter generate --abi ${abi_version}${lib.optionalString generate_from_json " src/grammar.json"}
      '';

    buildPhase = ''
      runHook preBuild

      ${lib.optionalString build "tree-sitter build -o parser.so"}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      ${lib.optionalString build ''
        mkdir -p $out/parser
        cp parser.so $out/parser/${name}.so
      ''}
      mkdir -p $out/queries
      ln -s ${nvim-treesitter}/runtime/queries/${name} $out/queries/${name}

      runHook postInstall
    '';

    passthru = { inherit requires tier; };
  }
  // removeAttrs args [
    "name"
    "src"
    "revision"
    "build"
    "generate_from_json"
    "location"
    "generate"
    "abi_version"
    "requires"
    "tier"
  ]
)
