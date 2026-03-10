{
  pkgs, # inputs,
  ...
}:
{
  home.packages = with pkgs; [
    nextcloud-client
    nemo
    foliate
    pdfarranger
    vesktop
    steam
    #inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    postman
    onlyoffice-desktopeditors
  ];
}
