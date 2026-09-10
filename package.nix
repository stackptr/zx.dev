{
  self,
  stdenv,
  cacert,
  pkgs,
  anemone,
}: let
  gitRev =
    if self ? rev
    then self.rev
    else "dirty";
  patchGitRev =
    if gitRev != "dirty"
    then ''
      sed -i "s|^#git_rev = .*|git_rev = \"${gitRev}\"|" config.toml
    ''
    else "";
in
  stdenv.mkDerivation {
    name = "zx.dev";
    src = ./.;
    buildInputs = [pkgs.zola];
    SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    buildPhase = "zola build";
    installPhase = ''
      mkdir -p $out
      cp -r dist/* $out/
    '';
    postPatch =
      ''
        mkdir -p themes/anemone
        cp -r ${anemone}/. themes/anemone/
      ''
      + patchGitRev;
  }
