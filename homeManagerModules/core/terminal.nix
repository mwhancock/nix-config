{ config, pkgs, ... }: {
  programs.ghostty.enable = true;
  home.file.".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/ghostty/.config/ghostty";
}
