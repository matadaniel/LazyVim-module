{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:

buildNpmPackage rec {
  pname = "markdown-toc";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "jonschlinkert";
    repo = pname;
    rev = version;
    hash = "sha256-CgyAxXcLrdk609qoXjyUgpA+NIlWrkBsE7lf5YnPagQ=";
  };

  postPatch = ''
    ln -s ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-y1S91Uy6HYN5clBlIp3cDQXN/YMSI8eqc1TulPyR6Ok=";

  dontNpmBuild = true;

  meta = {
    description = "Generate a markdown TOC (table of contents) with Remarkable.";
    homepage = "https://github.com/jonschlinkert/markdown-toc";
    license = lib.licenses.mit;
    mainProgram = "markdown-toc";
  };
}
