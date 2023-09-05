{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  };

  outputs = {
    self,
    nixpkgs,
  } @ inputs: {
    lib = import ./default.nix {inherit (nixpkgs) lib;};
  };
}
