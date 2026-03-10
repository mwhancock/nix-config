{ ... }:
{
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
      "dev.zed.Zed"
      "com.calibre_ebook.calibre"
      "app.grayjay.Grayjay"
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
