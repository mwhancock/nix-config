{ config, pkgs, ... }: {
  home.packages = [ pkgs.fish ];
  home.file.".config/fish".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/fish/.config/fish";
}
