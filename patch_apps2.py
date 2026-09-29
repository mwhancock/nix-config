with open("homeManagerModules/core/terminal.nix", "w") as f:
    f.write("""{ config, pkgs, ... }: {
  programs.ghostty.enable = true;
  home.file.".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/ghostty/.config/ghostty";
}
""")

with open("homeManagerModules/core/shell.nix", "w") as f:
    f.write("""{ config, pkgs, ... }: {
  programs.fish.enable = true;
  home.file.".config/fish".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/fish/.config/fish";
}
""")

with open("homeManagerModules/apps/zathura.nix", "w") as f:
    f.write("""{ config, pkgs, ... }: {
  programs.zathura.enable = true;
  home.file.".config/zathura".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/zathura/.config/zathura";
}
""")
