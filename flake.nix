{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils-plus = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  # outputs = {
  #   self,
  #   nixpkgs,
  # } @ inputs: let
  #   systems = ["x86_64-linux" "aarch64-linux"];
  # in {
  #   lib = import ./default.nix {inherit (nixpkgs) lib;};

  #   devShells = nixpkgs.lib.
  # };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    flake-utils-plus,
    ...
  } @ inputs:
    flake-utils-plus.lib.mkFlake {
      inherit self;
      inputs = {
        inherit (inputs) nixpkgs;
      };
      supportedSystems = flake-utils.lib.allSystems;

      lib.math = import ./default.nix {inherit (nixpkgs) lib;};
      test.mathOutput = import ./tests/test.nix {
        inherit (nixpkgs) lib;
        inherit (self.lib) math;
      };

      outputsBuilder = channels: let
        pkgs = channels.nixpkgs;

        python3 = pkgs.python3.withPackages (ps:
          with ps; [
            numpy
          ]);
      in {
        devShells.default = python3.env;
      };
    };
}
