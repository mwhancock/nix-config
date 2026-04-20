{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home.packages = with pkgs; [
    lazygit
    ripgrep
    fd
    fzf
    jdt-language-server
    clang-tools
    pyright
    python3
    bash-language-server
    nodejs
    # formatters
    stylua # lua (LazyVim configs are lua)
    prettierd # general
    black # Python
    clang-tools # clang-format for C
  ];
}
