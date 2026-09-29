{...}: {
  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = [
      "dev.aunetx.deezer" 
      "com.calibre_ebook.calibre"
      "app.grayjay.Grayjay"
      "com.bambulab.BambuStudio"
    ];
    update = {
      onActivation = true;
      auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };
  };
}
