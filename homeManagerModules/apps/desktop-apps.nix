{ pkgs
, inputs
, ...
}:
{
  home.packages = with pkgs; [
    foliate
    inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    nextcloud-client
    onlyoffice-desktopeditors
    pdfarranger
    postman
    steam
    trayscale
    vesktop
    zathura
  ];
}
