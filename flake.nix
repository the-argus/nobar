{
  description = "An alternative workflow for tiling window managers.";
  inputs.nixpkgs.url = github:nixos/nixpkgs?ref=nixos-22.11;

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    genSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgs = genSystems (system: import nixpkgs {inherit system;});
  in {
    homeManagerModule = import ./module.nix;

    packages = genSystems (system: rec {
      nobar = pkgs.${system}.callPackage ./. {};
      default = nobar;
    });
  };
}
