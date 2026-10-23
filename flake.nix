{
  description = "My NixOS flake";

  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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

    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    open-bamboo-networking = {
      url = "git+https://git.tjkeller.xyz/open-bamboo-network-plugin-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-tablet = {
      url = "github:GGEZUS/niri-tablet";
      flake = false;
    };

    # LumineCapture - Rust screenshot app built from git repo
    lumine-capture = {
      type = "git";
      url = "https://github.com/Netflate/LumineCapture";
      rev = "f8b526710ab188de45fd770e58be96dda98b8572";
      flake = false;
    };

    nixarchy = {
      url = "github:olafkfreund/nixarchy/main";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self,
      nixpkgs,
      agenix,
      home-manager,
      ...
    } @ inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = {
        agenix = agenix.packages.${system}.default;
      };

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            ./hosts/nixos
            inputs.nixarchy.nixosModules.nixarchy

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs system; };

                sharedModules = [ inputs.nixarchy.homeManagerModules.nixarchy ];

                users.mark = import ./hosts/nixos/home.nix;

                backupFileExtension = "bak";
                overwriteBackup = true;
              };
            }
          ];
        };
      };
    };
}
