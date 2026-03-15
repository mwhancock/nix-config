{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = false;
    viAlias = true;
    vimAlias = true;
  };

  home.packages = with pkgs; [
    lazygit
    ripgrep
    fd
    fzf

    jdt-language-server # Java
    clang-tools # C (clangd)
    pyright # Python
    python3 # Python runtime

    # formatters
    stylua # lua (LazyVim configs are lua)
    prettierd # general
    black # Python
    clang-tools # clang-format for C
  ];
}
