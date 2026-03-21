{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    fluffychat
    foliate
    inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    nextcloud-client
    onlyoffice-desktopeditors
    pdfarranger
    python314Packages.deemix
    postman
    trayscale
    vesktop
    zathura
  ];
}
