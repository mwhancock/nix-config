{ ... }:
{
  programs.nixvim.opts = {
    swapfile = false;
    number = true;
    relativenumber = true;
    tabstop = 4;
    shiftwidth = 4;
    expandtab = true;
    smartindent = true;
    wrap = true;
    scrolloff = 8;
    signcolumn = "yes";
    updatetime = 50;
    colorcolumn = "80";
    termguicolors = true;
  };
  programs.nixvim.globals = {
    mapleader = " ";
    maplocalleader = " ";
  };
}
