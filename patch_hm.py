import os

default_nix = "homeManagerModules/default.nix"
with open(default_nix, 'r') as f:
    content = f.read()

content = content.replace("    ./desktop/dank-material-shell.nix\n", "")
content = content.replace("    ./desktop/niri.nix\n", "    ./desktop/nixarchy.nix\n")

with open(default_nix, 'w') as f:
    f.write(content)

nixarchy_content = """{ pkgs, ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [
      pkgs.hyprlandPlugins.hyprscrolling
      pkgs.hyprlandPlugins.hyprgrass
    ];
  };
}
"""
with open("homeManagerModules/desktop/nixarchy.nix", 'w') as f:
    f.write(nixarchy_content)

os.remove("homeManagerModules/desktop/dank-material-shell.nix")
if os.path.exists("homeManagerModules/desktop/niri.nix"):
    os.remove("homeManagerModules/desktop/niri.nix")

