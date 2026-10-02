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

    niri-tablet = {
      url = "github:GGEZUS/niri-tablet";
      flake = false;
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
          # The system modules for this host are ./modules/*, imported by
          # hosts/nixos/configuration.nix. There is deliberately no nixModules/
          # directory: it was a second, parallel tree from the mfv3 era that
          # nothing imported, and it read like it was wired. See the commit that
          # removed it for the full audit; in short, every service in it was
          # already live, and three of its files would have broken this machine
          # (limine, snd-hda-intel model=alc256-asus-aio, and
          # power-profiles-daemon = false). modules/services/default.nix records
          # what was kept, what was dropped, and why -- including the WireGuard
          # key that this repository published to a public remote.
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

              # Back up a clashing file instead of aborting the activation.
              #
              # With these null (the defaults) Home Manager exits non-zero the
              # moment a managed file differs from what is on disk, and that
              # fails the whole home-manager unit: the system switch completes,
              # but nothing in the home environment is applied.
              #
              # It bites on ~/.config/ghostty/config. Omarchy appends
              # `config-file = ~/.config/omarchy/runtime/ghostty.conf` to that
              # file at runtime and the managed text does not have it, so HM
              # sees drift on every activation and always wants to back the
              # file up -- into the same ~/.config/ghostty/config.bak each time.
              #
              # Both options are needed, and the second is easy to miss:
              #
              #   backupFileExtension  what to append when moving a file aside.
              #                       Alone this is NOT enough. It converts the
              #                       "would be clobbered" failure into an
              #                       equally fatal "backup .bak already exists"
              #                       one -- same non-zero exit, next rebuild.
              #   overwriteBackup      replace an existing backup instead of
              #                       erroring. This is the half that actually
              #                       makes an update survive.
              #
              # Verified against the activation script's own collision logic
              # (check-link-targets.sh lines 26-35): with an existing .bak and
              # differing content, an empty overwrite flag records a collision
              # and fails, a set flag warns and continues.
              #
              # Cost: the backup is overwritten rather than kept, so the
              # previous version of a dotfile is not recoverable after the next
              # rebuild. That is the right trade for a handful of dotfiles this
              # repo can regenerate, and the wrong one for a profile holding
              # files this flake cannot regenerate.
              backupFileExtension = "bak";
              overwriteBackup = true;
            };
          }
        ];
      };
    };
  };
}
