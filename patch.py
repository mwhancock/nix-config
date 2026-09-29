import os
import sys

flake_path = "/home/mark/.gemini/antigravity-cli/brain/c409e275-304c-4314-9d9f-327597d11952/scratch/nix-config/flake.nix"
with open(flake_path, 'r') as f:
    content = f.read()

content = content.replace('''    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };''', '''    nixarchy = {
      url = "github:olafkfreund/nixarchy/main";
    };''')

content = content.replace('''          agenix.nixosModules.age''', '''          inputs.nixarchy.nixosModules.nixarchy
          agenix.nixosModules.age''')

content = content.replace('''              useUserPackages = true;
              users.mark = import ./hosts/mfv3/home.nix;''', '''              useUserPackages = true;
              sharedModules = [ inputs.nixarchy.homeManagerModules.nixarchy ];
              users.mark = import ./hosts/mfv3/home.nix;''')

with open(flake_path, 'w') as f:
    f.write(content)

config_path = "/home/mark/.gemini/antigravity-cli/brain/c409e275-304c-4314-9d9f-327597d11952/scratch/nix-config/hosts/mfv3/configuration.nix"
with open(config_path, 'r') as f:
    config_content = f.read()

config_content = config_content.replace('''  programs.fish.enable = true;''', '''  programs.fish.enable = true;
  programs.nixarchy.enable = true;''')

with open(config_path, 'w') as f:
    f.write(config_content)
