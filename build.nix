{ pkgs }:

let
  common = ./src/common.tex;

  hasSubstr =
    pat: s: builtins.isString pat && builtins.isString s && builtins.length (builtins.split pat s) > 1;

  mkDoc =
    templateStr: sections:
    let
      lines = builtins.split "\n" templateStr;
      sectionNames = builtins.attrNames sections;

      inject =
        line:
        let
          matched = builtins.filter (t: hasSubstr ("\\\\section\\*\\{" + t + "\\}") line) sectionNames;
        in
        if matched != [ ] then
          line
          + "\n"
          + builtins.concatStringsSep "\n" (
            map (f: "\\input{" + toString f + "}") sections.${builtins.head matched}
          )
        else
          line;

      allLines = builtins.map inject lines;
    in
    builtins.concatStringsSep "\n" (builtins.filter builtins.isString allLines);
in
{
  build =
    attrs:

    pkgs.stdenv.mkDerivation {
      name = "tex-document";
      src = ./.;

      nativeBuildInputs = [
        (
          with pkgs.texlive;
          combine {
            inherit
              scheme-basic
              latexmk
              collection-fontsrecommended

              geometry
              xcharter
              xstring
              xkeyval
              mweights
              fontaxes
              enumitem
              ;
          }
        )
      ];

      buildPhase = ''
        cat ${common} > main.tex
        echo "${mkDoc (builtins.readFile attrs.template) attrs.sections}" >> main.tex
        latexmk -pdf main.tex 
      '';

      installPhase = ''
        mkdir -p $out
        cp main.tex $out/
        cp main.pdf $out/
      '';
    };
}
