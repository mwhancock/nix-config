{ config, pkgs, ... }: {
  home.packages = [ pkgs.ghostty ];
  home.file.".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/ghostty/.config/ghostty";
}
