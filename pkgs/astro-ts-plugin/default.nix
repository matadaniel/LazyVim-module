{
  lib,
  stdenv,
  fetchFromGitHub,
  pnpm_8,
  nodejs_22,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "astro-ts-plugin";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "withastro";
    repo = "language-tools";
    rev = "@astrojs/ts-plugin@${finalAttrs.version}";
    hash = "sha256-WdeQQaC9AVHT+/pXLzaC6MZ6ddHsFSpxoDPHqWvqmiQ=";
  };

  pnpmDeps = pnpm_8.fetchDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmWorkspaces
      prePnpmInstall
      ;
    hash = "sha256-BiTrG5sfQmRQEmvZng+OxyUnuLH+rVe827BnICU9FPE=";
  };

  nativeBuildInputs = [
    nodejs_22
    pnpm_8.configHook
  ];

  buildInputs = [ nodejs_22 ];

  pnpmWorkspaces = [ "@astrojs/ts-plugin" ];
  prePnpmInstall = ''
    pnpm config set dedupe-peer-dependents false
  '';

  buildPhase = ''
    runHook preBuild

    pnpm --filter=@astrojs/ts-plugin build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r {packages/ts-plugin/{dist,LICENSE,package.json,README.md},node_modules} $out

    runHook postInstall
  '';

  meta = {
    description = "A TypeScript Plugin providing Astro intellisense";
    homepage = "https://github.com/withastro/language-tools";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
})
