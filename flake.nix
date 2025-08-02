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
        lib = pkgs.lib;

        builder = import ./build.nix { inherit pkgs; };
        mkDoc = builder.mkDoc;
      in
      {
        packages = {
          a = mkDoc [ ./src/content/work.tex ];
        };

        defaultPackage = self.packages.a;

        devShell = pkgs.mkShell {
          packages = with pkgs.texlive; [ (combine { inherit scheme-basic latexmk; }) ];
          shellHook = ''
            echo "Welcome to the tex devshell!"
          '';
        };
      }
    );
}
