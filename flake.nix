{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      flake = {
        lib.math = import ./default.nix { inherit (nixpkgs) lib; };
        test.mathOutput = import ./tests/test.nix {
          inherit (nixpkgs) lib;
          inherit (self.lib) math;
        };
      };

      perSystem =
        {
          config,
          system,
          pkgs,
          ...
        }:
        let
          python3 = pkgs.python3.withPackages (
            ps: with ps; [
              numpy
              pytest
            ]
          );
        in
        {
          apps.default = {
            type = "app";
            program = builtins.toString (
              pkgs.writeShellScript "test" ''
                set -euo pipefail
                exec ${python3}/bin/python3 -m pytest --verbose ${self}/tests/test.py
              ''
            );
          };

          devShells.default = python3.env;
        };
    };
}
