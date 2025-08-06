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
        builder = import ./build.nix { inherit pkgs; };

        variants = {
          a = {
            template = ./src/templates/a.tex;
            sections = {
              "Work Experience" = [
                ./src/content/work/work1.tex
                ./src/content/work/work2.tex
              ];
              "Education" = [
                ./src/content/work/work1.tex
              ];
              "Skills" = [
                ./src/content/work/work1.tex
              ];
            };
          };

          b = {
            template = ./src/templates/b.tex;
            sections = {
              "Work Experience" = [
                ./src/content/work/work1.tex
                ./src/content/work/work2.tex
                ./src/content/work/work3.tex
              ];
              "Research" = [
                ./src/content/work/work1.tex
              ];
            };
          };
        };
      in
      rec {
        packages = builtins.mapAttrs (name: cfg: builder.build cfg) variants;

        defaultPackage = packages.a;

        devShell = pkgs.mkShell {
          packages = with pkgs.texlive; [
            (combine { inherit scheme-basic latexmk; })
          ];
          shellHook = ''
            echo "Welcome to the tex devshell!"
          '';
        };
      }
    );
}
