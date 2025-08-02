{ pkgs }:
let
  template = ./src/templates/a.tex;

  mkInputs =
    sections: pkgs.lib.concatStringsSep "\n" (map (f: "\\input{" + toString f + "}") sections);

  mkDoc =
    snippetFiles:
    let
      inputs = mkInputs snippetFiles;

      mainTex = pkgs.writeText "main.tex" ''
        \input{${toString template}}
        ${inputs}

        \end{document}
      '';
    in
    pkgs.stdenv.mkDerivation {
      name = "doc";
      src = ./.;

      nativeBuildInputs = [
        (
          with pkgs.texlive;
          combine {
            inherit scheme-basic latexmk;
          }
        )
      ];

      buildPhase = ''
        cp ${mainTex} main.tex
        latexmk -pdf main.tex
      '';

      installPhase = ''
        mkdir -p $out
        cp main.pdf $out/
      '';
    };
in
{
  mkDoc = mkDoc;
}
