{
  description = "Example development environment flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tex =
          with pkgs;
          texlive.combine {
            inherit (texlive) scheme-basic latexmk;
          };
      in
      {
        defaultPackage = pkgs.stdenv.mkDerivation {
          name = "latex-document";
          src = ./.;
          nativeBuildInputs = [
            tex
          ];

          buildPhase = ''
            latexmk -pdf main.tex
          '';

          installPhase = ''
            mkdir -p $out
            cp main.pdf $out/
          '';
        };
        devShell = pkgs.mkShell {
          packages = [ tex ];
          shellHook = ''
            echo Welcome to the tex devshell!
          '';
        };
      }
    );
}
