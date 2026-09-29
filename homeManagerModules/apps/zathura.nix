{ config, pkgs, ... }: {
  programs.zathura.enable = true;
  home.file.".config/zathura".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/zathura/.config/zathura";
}
