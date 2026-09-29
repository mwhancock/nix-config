{ config, pkgs, ... }: {
  home.packages = [ pkgs.zathura ];
  home.file.".config/zathura".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/zathura/.config/zathura";
}
