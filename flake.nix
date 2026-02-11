{
  description = "Flake for glide-browser";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };

  outputs = { self, nixpkgs, ... }:
  let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (system:
      let
        pkgs = import nixpkgs { inherit system; };
        glide = pkgs.callPackage ./package.nix { };
      in rec {
        glide-browser-unwrapped = glide;
        glide-browser = pkgs.wrapFirefox glide-browser-unwrapped {};
        default = glide-browser;
      }
    );

    apps = forAllSystems (system: {
      default = let
        pkg = self.packages.${system}.default;
        mainProgram = pkg.meta.mainProgram;
      in {
        type = "app";
        program = "${pkg}/bin/${mainProgram}";
      };
    });

    overlays.default = final: prev: {
      glide-browser = final.callPackage ./package.nix { };
    };
  };
}
