{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:

buildNpmPackage rec {
  pname = "vtsls";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "yioneko";
    repo = pname;
    rev = "server-v${version}";
    hash = "sha256-rbvM/2U88Qd6cHbUrQMNUOKebY15IQsBHG7C0yeeJyA=";
  };

  sourceRoot = "${src.name}/packages/server";

  postPatch = ''
    ln -s ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-gB43R76lsLNJ/e4XcUBP1T8Nwk/oWM01STmpg9y6xzA=";

  meta = {
    description = "LSP wrapper for typescript extension of vscode";
    homepage = "https://github.com/yioneko/vtsls#readme";
    license = lib.licenses.mit;
    mainProgram = "vtsls";
  };
}
