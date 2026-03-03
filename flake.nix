{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-25.11 branch here
    ghostty.url = "github:ghostty-org/ghostty";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    zed.url = "github:zed-industries/zed";
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zen-browser, zed, ghostty, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {

      packages.${system}.zed-latest = zed.packages.${system}.default;
      inputs.ghostty.${pkgs.stdenv.hostPlatform.system}.default;

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
      ];
    };
  };
}
