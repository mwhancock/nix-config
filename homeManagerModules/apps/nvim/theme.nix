{ pkgs, ... }:
{
  programs.nvf.settings.vim = {
    theme = {
      enable = true;
      name = "gruvbox";
      style = "dark";
      transparent = false;
    };

    extraPlugins = with pkgs.vimPlugins; {
      gruvbox = {
        package = gruvbox-nvim;
        setup = ''
          require("gruvbox").setup({
            contrast = "hard",
            transparent_mode = false,
          })
        '';
      };
    };
  };
}
