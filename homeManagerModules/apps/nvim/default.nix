{ config, pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [ pandoc tectonic zathura ripgrep fd ];
  };

  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/neovim/.config/nvim";
}
