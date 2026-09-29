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
    dsearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    matugen = {
      url = "github:/InioX/Matugen";
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opencode = {
      url = "github:dan-online/opencode-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixarchy = {
      url = "github:olafkfreund/nixarchy/main";
      inputs.home-manager.follows = "home-manager";
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
          disko.nixosModules.disko
          ./hosts/mfv3/disko-config.nix
          ./nixModules
          inputs.nixarchy.nixosModules.nixarchy
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
              sharedModules = [ inputs.nixarchy.homeManagerModules.nixarchy ];
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
