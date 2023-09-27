{
  description =
    "My Nix-flake-based Common Lisp development environment using SBCL";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, mach-nix, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      perSystem = { self', pkgs, config, system, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.permittedInsecurePackages =
              [ "openssl-1.1.1v" "openssl-1.1.1w" ];
            overlays = [
              (final: prev: rec {
                mysbcl = prev.lispPackages_new.sbclWithPackages
                  (ps: with ps; [ swank bordeaux-threads cl-ppcre ]);
                myccl = prev.lispPackages_new.cclWithPackages
                  (ps: with ps; [ swank bordeaux-threads cl-ppcre ]);
              })
            ];
          };
          name = "{{ cookiecutter.project_name}}";
          src = ./.;
          nativeBuildInputs = with pkgs; [ gnumake myccl mysbcl ];
        in {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [ nixpkgs-fmt ] ++ nativeBuildInputs;
          };

          packages = {
            ${name} = derivation {
              inherit system name src;
              nativeBuildInputs = nativeBuildInputs;
              builder = with pkgs; "${bash}/bin/bash";
              args = [ "-c" "make" ];
            };
            default = config.packages.${name};
          };
        };
    };
}
