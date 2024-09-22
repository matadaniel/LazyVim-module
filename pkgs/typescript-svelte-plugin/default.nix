{
  lib,
  stdenv,
  fetchFromGitHub,
  pnpm_9,
  nodejs_22,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "typescript-svelte-plugin";
  version = "0.3.41";

  src = fetchFromGitHub {
    owner = "sveltejs";
    repo = "language-tools";
    rev = "typescript-plugin-${finalAttrs.version}";
    hash = "sha256-IGmjuAqFiKPZ0G/zg48284cQBJqA0/4vSwE3dT7pqQ4=";
  };

  pnpmDeps = pnpm_9.fetchDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmWorkspace
      prePnpmInstall
      ;
    hash = "sha256-uIb5yZEqf/vjxblOaFwUzLObW1np09abYx6BNQ5uIIk=";
  };

  nativeBuildInputs = [
    nodejs_22
    pnpm_9.configHook
  ];

  buildInputs = [ nodejs_22 ];

  pnpmWorkspace = "typescript-svelte-plugin";
  prePnpmInstall = ''
    pnpm config set dedupe-peer-dependents false
  '';

  buildPhase = ''
    runHook preBuild

    pnpm --filter=typescript-svelte-plugin build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r {packages/typescript-plugin/{dist,package.json,README.md},LICENSE,node_modules} $out

    runHook postInstall
  '';

  meta = {
    description = "A TypeScript Plugin providing Svelte intellisense";
    homepage = "https://github.com/sveltejs/language-tools/tree/master/packages/typescript-plugin";
    license = lib.licenses.mit;
  };
})
