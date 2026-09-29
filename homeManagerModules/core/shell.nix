{ config, pkgs, ... }: {
  programs.fish.enable = true;
  home.file.".config/fish".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/fish/.config/fish";
}
