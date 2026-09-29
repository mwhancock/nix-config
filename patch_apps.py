import os

def remove_settings(filepath, package_name):
    with open(filepath, 'r') as f:
        content = f.read()
    # we can just rewrite the files simply
    pass

with open("homeManagerModules/core/terminal.nix", "w") as f:
    f.write("""{ pkgs, ... }: {
  home.packages = [ pkgs.ghostty ];
  home.file.".config/ghostty".source = /home/mark/dotfiles/ghostty/.config/ghostty;
}
""")

with open("homeManagerModules/core/shell.nix", "w") as f:
    f.write("""{ pkgs, ... }: {
  home.packages = [ pkgs.fish ];
  home.file.".config/fish".source = /home/mark/dotfiles/fish/.config/fish;
}
""")

with open("homeManagerModules/apps/zathura.nix", "w") as f:
    f.write("""{ pkgs, ... }: {
  home.packages = [ pkgs.zathura ];
  home.file.".config/zathura".source = /home/mark/dotfiles/zathura/.config/zathura;
}
""")

# cli-tools
with open("homeManagerModules/apps/cli-tools.nix", "r") as f:
    cli_tools = f.read()
# Let's just add yazi and aider sources to cli-tools.nix
# We'll just replace the whole file for simplicity or append.
