{
  description = "My NixOS flake";

  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    zen-backup = {
      url = "github:Ronin-CK/Zen-Backup-Tool";
      flake = false;
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dsearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    matugen = {
      url = "github:/InioX/Matugen";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    nixpkgs,
    agenix,
    home-manager,
    nix-flatpak,
    disko,
    ...
  } @ inputs: let
    system = "x86_64-linux";
  in {
    packages.${system} = {
      agenix = agenix.packages.${system}.default;
    };

    nixosConfigurations = {
      # --- Minisforum V3 (Laptop) ---
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          {nixpkgs.hostPlatform = "x86_64-linux";}
          ./hosts/mfv3/configuration.nix
          ./nixModules
          agenix.nixosModules.age
          nix-flatpak.nixosModules.nix-flatpak
          {
            age.identityPaths = ["/home/mark/.ssh/id_ed25519"];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.mark = import ./hosts/mfv3/home.nix;
              extraSpecialArgs = {inherit inputs;};
              backupFileExtension = "bak";
            };
          }
        ];
      };

      # --- Pangolin (Server) ---
      server = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          disko.nixosModules.disko
          ./hosts/server/disko-config.nix
          ./hosts/server/configuration.nix
          ./nixModules/core/base.nix
          ./nixModules/core/boot.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.mark = import ./hosts/server/home.nix;
              extraSpecialArgs = {inherit inputs;};
              backupFileExtension = "bak";
            };
          }
        ];
      };
    };
  };
}
