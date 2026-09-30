# Fish as the login shell, plus the pieces the dotfiles' fish config expects.
#
# The dotfiles at dotfiles/fish/.config/fish reference starship, direnv, zoxide,
# eza, fnm and bat. Those are all declared here so `config.fish` works on a
# fresh activation rather than degrading to a series of no-ops.
{ config, pkgs, lib, ... }:

{
  # No interactiveShellInit here on purpose. The vendored
  # dotfiles/fish/.config/fish/config.fish already runs starship, direnv and
  # zoxide behind `status is-interactive`, and hosts/nixos/home.nix installs
  # that file at ~/.config/fish. Declaring the same three lines here as well
  # would source every tool twice on every interactive shell.
  programs.fish.enable = true;

  # The login shell is set in hosts/nixos/default.nix, so the account definition
  # stays in one place.
  environment.systemPackages = with pkgs; [
    fish
    starship
    direnv
    zoxide
    eza
    bat
    fnm
    fzf
    lazygit
    yazi
    btop
    fastfetch
  ];
}