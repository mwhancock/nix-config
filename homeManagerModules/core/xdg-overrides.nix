{pkgs, ...}: {
  xdg.configFile."fontconfig/conf.d/10-hm-fonts.conf".force = true;
  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/gtk.css".force = true;
  xdg.desktopEntries.nemo = {
    name = "Nemo";
    exec = "${pkgs.nemo-with-extensions}/bin/nemo";
  };
  xdg.desktopEntries.nvim = {
    name = "Neovim";
    exec = "ghostty -e nvim %F";
    terminal = false;
    mimeType = [
      "text/plain"
      "text/x-c"
      "text/x-csrc"
      "text/x-chdr"
      "text/x-java"
      "text/x-python"
      "application/x-shellscript"
    ];
  };
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = ["thunar.desktop"];
      "text/plain" = ["nvim.desktop"];
      "text/x-c" = ["nvim.desktop"];
      "text/x-csrc" = ["nvim.desktop"];
      "text/x-chdr" = ["nvim.desktop"];
      "text/x-java" = ["nvim.desktop"];
      "text/x-python" = ["nvim.desktop"];
      "application/x-shellscript" = ["nvim.desktop"];
      "application/pdf" = ["org.pwmt.zathura.desktop"];
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = ["onlyoffice-desktopeditors.desktop"];
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = ["onlyoffice-desktopeditors.desktop"];
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = ["onlyoffice-desktopeditors.desktop"];
      "application/msword" = ["onlyoffice-desktopeditors.desktop"];
      "application/vnd.ms-excel" = ["onlyoffice-desktopeditors.desktop"];
      "application/vnd.ms-powerpoint" = ["onlyoffice-desktopeditors.desktop"];
      "application/vnd.oasis.opendocument.text" = ["onlyoffice-desktopeditors.desktop"];
      "application/vnd.oasis.opendocument.spreadsheet" = ["onlyoffice-desktopeditors.desktop"];
      "application/vnd.oasis.opendocument.presentation" = ["onlyoffice-desktopeditors.desktop"];
    };
    associations.removed = {
      "application/pdf" = [
        "com.calibre_ebook.calibre.desktop"
        "com.github.jeromerobert.pdfarranger.desktop"
      ];
    };
  };
  xdg.configFile."pandoc/defaults.yaml".text = ''
    pdf-engine: tectonic
    variables:
      mainfont: "Inter"
      fontsize: 11pt
      geometry: margin=1in
      fontfamily: "inter"
    metadata:
      author: "Mark"
  '';
}
