{
  description = "My NixOS flake";

  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
    ...
  } @ inputs: let
    system = "x86_64-linux";
  in {
    packages.${system} = {
      agenix = agenix.packages.${system}.default;
    };

    nixosConfigurations = {
      # --- Minisforum V3 (Laptop) ---
      #
      # Was hosts/mfv3, which imported disko and a disko layout describing
      # /dev/nvme0n1 as btrfs. This machine is ext4. `nixos` the output name is
      # unchanged so that `nixos-rebuild switch` and `nh os switch` keep working
      # against this flake with no extra arguments; what changed is which host
      # directory it resolves to.
      #
      # Three imports are gone, each for a reason recorded at the call site:
      #   disko.nixosModules.disko + hosts/mfv3/disko-config.nix
      #     -- the destructive one. See hosts/nixos/configuration.nix.
      #   nix-flatpak.nixosModules.nix-flatpak
      #     -- flatpak is nixarchy's to manage.
      #   agenix.nixosModules.age + age.identityPaths = [ "/home/mark/.ssh/id_ed25519" ]
      #     -- there are no age.secrets in this repository, so the module does
      #        nothing, and the identity path it named does not exist on this
      #        machine (there is no ~/.ssh at all). Reintroduced when there is
      #        something to decrypt.
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          {nixpkgs.hostPlatform = "x86_64-linux";}
          ./hosts/nixos
          inputs.nixarchy.nixosModules.nixarchy

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              sharedModules = [ inputs.nixarchy.homeManagerModules.nixarchy ];
              users.mark = import ./hosts/nixos/home.nix;
              extraSpecialArgs = {inherit inputs;};
              backupFileExtension = "bak";
            };
          }
        ];
      };
    };
  };
}
