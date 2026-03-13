{
  pkgs,
  inputs,
  ...
}:
{
  home.packages = with pkgs; [
    foliate
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    # inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
    #inputs.matugen.packages.${pkgs.stdenv.hostPlatform.system}.default
    nemo
    nextcloud-client
    onlyoffice-desktopeditors
    pdfarranger
    postman
    steam
    trayscale
    vesktop
    #zed-editor
  ];
}
