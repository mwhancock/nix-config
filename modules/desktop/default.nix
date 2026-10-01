# Desktop configuration that is NOT nixarchy's job.
#
# Deliberately short. Everything here is a decision that had to be made against
# the old repo, or an adjustment for this particular machine. Anything that
# nixarchy already owns is left to nixarchy -- that is the whole point of
# running nixarchy rather than a from-scratch Hyprland config.
{ config, lib, pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # Touchpad and touchscreen: NOT SET HERE, ON PURPOSE.
  #
  # Niri's distinguishing input behaviour is natural scrolling plus a
  # three-finger horizontal swipe along its infinite strip. The Hyprland
  # equivalent belongs in ~/.config/hypr/input.lua:
  #
  #   hl.config({
  #     input    = { touchpad = { natural_scroll = true } },
  #     gestures = {
  #       workspace_swipe_fingers     = 3,
  #       workspace_swipe_distance    = 300,
  #       workspace_swipe_create_new  = false,
  #       workspace_swipe_touch       = true,
  #       workspace_swipe_touch_invert = false,
  #     },
  #   })
  #   hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
  #
  # It is not configured declaratively because there is nothing to configure it
  # with. Nixarchy exposes no `programs.nixarchy.hyprland` option -- its options
  # are package, neovim, neovimSpecs, defaultTheme, plugins, defaultPlugins,
  # defaultPluginSet and pluginChecks, and none of them reach Hyprland's
  # settings. Hyprland configuration on this machine is a real file the user
  # edits:
  #
  #   -rw-r--r-- mark users ~/.config/hypr/input.lua     (2118 bytes, not a
  #                                                            store symlink)
  #
  # and nixarchy seeds it only when absent. Overwriting it through Home Manager
  # would take the file away from the user and from Hyprforge, which manages the
  # same settings through its own state file at
  # ~/.local/state/omarchy/toggles/hypr/flags.lua.
  #
  # Live values read before writing anything, so the change is measurable:
  #   input:touchpad:natural_scroll   false (set: true)
  #   gestures:workspace_swipe_touch   false (set: false)
  #
  # The gesture keys above are all present in Hyprland 0.56.0 (the running
  # version) and are listed in nixarchy's Hyprforge schema, so they are the
  # supported names rather than guesses.
  #
  # This machine does report a multitouch panel: HID 222a:550d on
  # i2c-PNP0C50:00 decodes to ABS_MT_SLOT / ABS_MT_POSITION_X,Y /
  # ABS_MT_TRACKING_ID, and `hyprctl devices` lists it under both Touch and
  # Tablets. That is why workspace_swipe_touch is worth setting. Unverified in
  # person -- the digitizer reports 303x190mm, a fingerprint-sensor-sized
  # surface rather than a display-sized one, so it may be the Goodix reader's
  # HID interface. If swiping the screen does nothing, that is why; the setting
  # is harmless either way.
  #
  # workspace_swipe_create_new is false rather than true on purpose: niri's
  # strip is spatial, so swiping back always returns to where you came from.
  # Creating a new workspace past the end is not that behaviour.

  # ---------------------------------------------------------------------------
  # Thunar with its archive and volume plugins, which hosts/mfv3/desktop/thunar.nix
  # configured. Nixarchy does not pick a file manager, so this is still a real
  # decision rather than a conflict.
  programs.thunar = {
    enable = false;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # ---------------------------------------------------------------------------
  # Not carried over:
  #
  #   services.desktopManager.gnome.enable = false   and
  #   services.displayManager.gdm.enable = false      (mfv3/display-manager.nix)
  #     Nixarchy picks the session and the greeter. Disabling both here would
  #     leave the machine with no display manager at all.
  #
  #   services.gnome.* (mfv3/gnome.nix)
  #     Excluded GNOME core apps to slim the image. Nixarchy installs what the
  #     desktop needs. Only gnome-themes-extra and adwaita-icon-theme survive,
  #     in modules/packages.
  #
  #   boot.extraModprobeConfig + boot.kernelParams forcing
  #     model=alc256-asus-aio, and blacklisting snd_acp_pci (mfv3/core/boot.nix,
  #     mfv3/hardware/audio.nix)
  #     ASUS firmware for an ASUS codec on a Minisforum ALC245, while the
  #     machine's audio runs through snd_sof_amd_acp. snd_acp_pci is loaded and
  #     referenced by snd_amd_acpi_mach as of this writing. Removing the
  #     blacklist takes effect on the next boot; nothing un-blacklists it
  #     earlier, so the only way to learn whether it was ever needed is to
  #     remove it and keep audio working.
  #
  #   boot.loader.limine
  #     See hosts/nixos/configuration.nix. systemd-boot stays.
  #
  #   The gruvbox GTK/session theming from homeManagerModules/core/gtk.nix
  #     You asked to keep the omarchy theme, so the forced gruvbox is gone.
}
