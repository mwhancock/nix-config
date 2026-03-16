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
    termguicolors = true;
    clipboard = "unnamedplus";
  };
  programs.nixvim.globals = {
    mapleader = " ";
    maplocalleader = " ";
  };
  programs.nixvim.autoCmd = [
    {
      event = [ "FocusLost" "BufLeave" ];
      callback = {
        __raw = ''
          function()
          if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" then
              vim.cmd("silent! write")
              end
              end
        '';
      };
    }
  ];
}
