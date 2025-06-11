{
  stdenv,
  pkgs,
  anemone,
}:
stdenv.mkDerivation {
  name = "zx.dev";
  src = ./.;
  buildInputs = [pkgs.zola];
  buildPhase = "zola build";
  installPhase = ''
    mkdir -p $out
    cp -r dist/* $out/
  '';
  postPatch = ''
    mkdir -p themes/anemone
    cp -r ${anemone}/. themes/anemone/
  '';
}
