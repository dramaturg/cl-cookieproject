{
  description =
    "My Nix-flake-based Common Lisp development environment using {{ cookiecutter.lisp }}";

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
                my{{ cookiecutter.lisp }} = prev.lispPackages_new.{{ cookiecutter.lisp }}WithPackages
                  (ps: with ps; [ {{ cookiecutter.lisp_libraries }} ]);
              })
            ];
          };
          name = "{{ cookiecutter.project_name}}";
          src = ./.;
          nativeBuildInputs = with pkgs; [ gnumake my{{ cookiecutter.lisp }} ];
        in {
          devShells.default = pkgs.mkShell {
            LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [ openssl_1_1 ];
            buildInputs = with pkgs; [ nixpkgs-fmt ] ++ nativeBuildInputs;
          };

          packages = {
            ${name} = derivation {
              inherit system name src;
              LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [ openssl_1_1 ];
              nativeBuildInputs = nativeBuildInputs;
              builder = with pkgs; "${bash}/bin/bash";
              args = [ "-c" "make build" ];
            };
            default = config.packages.${name};
          };
        };
    };
}
