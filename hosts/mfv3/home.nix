{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.nvf.homeManagerModules.default
    ../../homeManagerModules/default.nix
  ];
  home.sessionVariables = {
    PATH = "$HOME/.local/bin:$PATH";
  };
  home.enableNixpkgsReleaseCheck = false;
  home.username = "mark";
  home.homeDirectory = "/home/mark";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
  programs.quickshell.enable = true;
  gtk.gtk4.theme = config.gtk.theme;
  programs.man.enable = false;

  home.file."/home/mark/Nextcloud/Documents/School/metadata.yaml".text = ''
    \usepackage{fontspec}
    \setmainfont{Inter}
    \usepackage{titling}

    \pretitle{\begin{center}\LARGE\bfseries}
    \posttitle{\end{center}\vskip 1.5em}
    \preauthor{\begin{center}\large Mark Hancock \par \vskip 1em Student \# 20140473 \end{center}}
    \postauthor{\vskip 1.5em}
    \predate{\begin{center}\large}
    \postdate{\end{center}\vfill\newpage}
  '';
}
