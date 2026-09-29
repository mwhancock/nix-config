{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    neovim pandoc tectonic zathura ripgrep fd
  ];

  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/neovim/.config/nvim";
}
