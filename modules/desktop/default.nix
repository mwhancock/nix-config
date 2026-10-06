# Desktop configuration that is NOT nixarchy's job.
#
# Deliberately short. Everything here is a decision that had to be made against
# the old repo, or an adjustment for this particular machine. Anything that
# nixarchy already owns is left to nixarchy -- that is the whole point of
# running nixarchy rather than a from-scratch Hyprland config.
{ config, lib, pkgs, inputs, ... }:

{
  # ---------------------------------------------------------------------------
  # Foot, Chromium and Evince are not installed.
  #
  # These three are the awkward ones. None of the routes that work for the rest:
  # they are not nixarchy `preinstalls` (so `preinstallsExclude` cannot name
  # them), they appear nowhere in this flake, and `programs.nixarchy.package`
  # cannot be used either -- `runtimeDeps` is a `let` binding inside
  # pkgs/omarchy/default.nix, not a function argument, so `.override` rejects it
  # ("called with unexpected argument 'runtimeDeps'"). Nor is the usual-looking
  # `environment.systemPackages = lib.mkForce (filter ... config
  # .environment.systemPackages)`: that self-reference is infinite recursion, and
  # it was tested rather than assumed.
  #
  # What does work is the overlay in modules/packages/removed.nix, which
  # shadows the three nixpkgs attributes with empty packages. nixarchy's
  # runtimeDeps holds these as ordinary `pkgs` references, so it picks up the
  # shadowed versions and nothing lands in `environment.systemPackages`.
  #
  # foot      The only terminal in `xdg-terminal-exec`'s preference list, so
  #           removing it without replacing that would break "Open Terminal"
  #           and anything else shelling out to it. ~/.config/xdg-terminals.list
  #           points xdg-terminal-exec at ghostty, which is already the terminal
  #           nixarchy launches and the one ~/.config/ghostty/ configures.
  # chromium  Not wanted as a browser.
  # evince    GNOME Document Viewer. PDF reading happens in zathura instead,
  #           kept in modules/packages/default.nix.
  #
  # Nautilus (Files) is deliberately left alone -- it stays.

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
  # Niri as a second Wayland session, alongside the Nixarchy one.
  #
  # This exists because Noctalia was installed (pkgs.noctalia, declared in
  # hosts/nixos/nixarchy/apps.nix alongside the other plain packages), and
  # Noctalia is not a session. It ships no .desktop entry because it does not
  # own a display -- it is a Quickshell shell that draws on top of a compositor
  # that is already running. So "which shell do I log into" is not a question
  # Noctalia can answer; the question is which compositor.
  #
  # Enabling programs.niri is what turns that into a real choice: the module
  # writes share/wayland-sessions/niri.desktop, so the greeter gains a "niri"
  # entry next to "Nixarchy", "Hyprland" and "Hyprland (uwsm)". Nothing is
  # autostarted and no existing session changes -- niri only runs if chosen.
  #
  # The three sessions already on this machine are all the same compositor:
  #
  #   Nixarchy          -> omarchy-session, i.e. Hyprland plus Omarchy's config
  #   Hyprland          -> plain Hyprland
  #   Hyprland (uwsm)   -> the same, started through uwsm
  #
  # which is why Omarchy and Hyprland were never alternatives here. Omarchy is
  # a config and theme layer over Hyprland, not a separate desktop.
  #
  # niri 26.04 from this flake's own pinned nixpkgs. Deliberately NOT enabled:
  #
  #   programs.niri.useNautilus
  #       Would set niri's preferred file manager to Nautilus, overriding
  #       xdg-user-dir. Nautilus stays (see the note above), but niri's own
  #       default is left alone: this flake never asked for Nautilus to be the
  #       opener, and setting it from the niri module would do it as a side
  #       effect of adding a session.
  #
  # Not wired up here, and worth knowing before logging in:
  #
  #   ~/.config/niri and ~/.config/noctalia are both wired up, in
  #   hosts/nixos/home.nix, as out-of-store symlinks to dotfiles/niri and
  #   dotfiles/noctalia. The second copy of the sentence above was wrong for a
  #   while: homeManagerModules/apps/ does carry per-app mkOutOfStoreSymlink
  #   entries, but that whole tree is inert (home.nix imports only
  #   core/fonts.nix), so they were never deploying anything. The live entries
  #   went next to the other home.file declarations instead.
  #
  #   That config needed a fix before it could load. Its touchscreen gesture
  #   block (show-touch-points, touchscreen-swipe, touchscreen-edge-swipe) is
  #   niri-tablet syntax, not upstream niri; stock niri 26.04 rejects all three
  #   nodes and refuses to start on a config that fails to parse, so the session
  #   could not boot. It is live again now that programs.niri.package builds
  #   from the patchset -- with three node names renamed, because the patchset
  #   renamed them upstream of this config:
  #
  #     tap-4          -> tap-more
  #     swipe-4-down   -> swipe-more-down
  #     swipe-4-up     -> swipe-more-up
  #
  #   Patches 0019 ("derive the tap/flick tier from fingers") and 0020 are what
  #   did it: the extra-finger binds used to be hardcoded to 4 and are now
  #   derived from `fingers`, so they are named -more rather than -4. Confirmed
  #   against the patched parser's struct -- TouchscreenSwipePart has tap_more,
  #   swipe_more_down, swipe_more_up, swipe_more_left, swipe_more_right -- and
  #   not just against the fork's example config.
  #
  #   There is no bar conflict to solve, contrary to what this comment claimed
  #   before it was checked. Omarchy's bar is Quickshell, started by
  #   omarchy-launch-shell, and that is called from the Hyprland config at
  #   share/omarchy/default/hypr/autostart.lua. Only Hyprland reads that file,
  #   so in an niri session the Nixarchy bar never starts and Noctalia is the
  #   only bar.
  #
  #   What does cross over is two enabled systemd user units, which start
  #   regardless of compositor because they are enabled system-wide rather than
  #   launched from the Hyprland config -- and both are gated on
  #   ConditionEnvironment=WAYLAND_DISPLAY, which niri also sets:
  #
  #     omarchy-sleep-lock.service    runs hyprlock, which cannot lock under
  #                                 niri. Noctalia has its own lock screen, so
  #                                 the capability is not lost, but the unit
  #                                 errors on suspend.
  #     xdg-desktop-portal-hyprland   the wrong portal backend. niri does
  #                                 screencast natively, so the cost is small,
  #                                 but it is not what niri documents.
  #
  #   Both are left enabled on purpose. Masking them per session means a drop-in
  #   keyed on XDG_CURRENT_DESKTOP -- "niri" in niri, "Hyprland" in the Nixarchy
  #   session -- which works today and is one rename away from silently skipping
  #   the lock screen in the session that matters. A failing unit in a session
  #   being trialled is the cheaper mistake. Say so and they can be gated.

  # The patch is here, and only here, because this machine has a touchscreen.
  #
  # The digitizer on i2c-PNP0C50:00 (HID 222a:550d) reports
  #
  #   ID_INPUT_TOUCHSCREEN=1  ID_INPUT_WIDTH_MM=303  ID_INPUT_HEIGHT_MM=190
  #
  # 303x190mm is a 14" 16:10 panel's active area -- 357.6mm diagonal, 14.08" --
  # and it matches the internal display's own EDID figures (BOE 0x0B7B,
  # 300x190mm from `hyprctl monitors`) to within rounding. That is a touchscreen
  # the size of the screen it sits on.
  #
  # An earlier version of this comment called it a fingerprint reader, on the
  # grounds that a digitizer "reporting 303x190mm" was absurdly large for a
  # fingerprint sensor. That was wrong, and wrong in a way worth recording: the
  # number was never sanity-checked against what a 14" panel actually measures.
  # A Goodix fingerprint sensor is on the order of 15x6mm. Nothing about this
  # device resembles that.
  #
  # The reason it matters is not the touchscreen itself -- niri has supported
  # touch drag-to-move, edge-scroll and hot corners for a long time -- it is the
  # multi-finger gesture binds in dotfiles/niri/.config/niri/config.kdl, which
  # need the patchset because upstream has no touchscreen gestures at all.
  programs.niri = {
    enable = true;
    package = pkgs.callPackage ../packages/niri-tablet.nix { niri-tablet = inputs.niri-tablet; };
  };

  # ---------------------------------------------------------------------------
  # Login screen: greetd + Noctalia Greeter, not SDDM.
  #
  # SDDM cannot pick a session on this machine, and that is the entire reason
  # for this section. Nixarchy sets sddm.theme = "omarchy", and that theme has
  # no session picker: in share/sddm/themes/omarchy/Main.qml, sessionIndex is
  # read once at sddm.login() (line 106) and assigned nowhere in the file. So
  # the greeter can only ever start whichever session SDDM was configured for,
  # with no UI to change it. Before niri that was merely a missing feature; after
  # niri it was a real trap, because a second session existed and could not be
  # reached.
  #
  # Noctalia Greeter does have the picker, plus a colour-scheme toggle, and it
  # reads the same desktop entries SDDM did -- so every session still shows up.
  #
  # programs.nixarchy.displayManager = false is the documented switch for this,
  # and its own option description names greetd explicitly. Setting
  # sddm.enable = false directly would also work but fights the mkDefault
  # instead of using the switch meant for it.
  #
  # The nixpkgs module does the rest and none of it is repeated here: it enables
  # greetd, points default_session.command at noctalia-greeter-session, enables
  # accounts-daemon for the user avatars, and enables polkit for the optional
  # appearance sync.
  programs.nixarchy.displayManager = false;

  services.displayManager.noctalia-greeter = {
    enable = true;

    settings = {
      # The picker's label, i.e. the desktop entry's Name= -- "Niri", not
      # niri.desktop. This is also what makes nixpkgs' programs.niri
      # mkDefault of displayManager.defaultSession = "niri" agree with the
      # greeter, so the two paths into the session agree instead of drifting.
      #
      # It goes in the TOML settings rather than onto the greetd command line
      # because TOML quoting is what keeps a name containing spaces from being
      # re-split by greetd; "Hyprland (uwsm-managed)" as a bare command argument
      # leaves the VT unusable. pkgs.formats.toml handles the quoting.
      session.default = "Niri";

      # Skip the user list and open the password step for this account. There is
      # exactly one human user, so the list is a step that can only be misclicked.
      user.default = "mark";

      cursor.size = 24;
    };

    # Omarchy's cursor, so the pointer does not change appearance at the login
    # boundary. cursorTheme.name rather than settings.cursor.theme, because the
    # module fills that key in with a mkDefault whenever a package is given --
    # setting both would be two answers to one question.
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };
  };

  # Appearance is deliberately not pinned here. The greeter will take a
  # [appearance.palette] from this file and it outranks anything Sync writes, so
  # hardcoding Gruvbox now would silently win over the Noctalia shell forever
  # after and would have to be maintained by hand. The supported route is
  # Settings -> Shell -> Security -> Noctalia Greeter -> Sync Now, with polkit
  # already enabled above; the greeter then reads wallpaper and palette from
  # Noctalia the same way the session does.

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
  # A polkit authentication agent, because without one no polkit prompt on this
  # machine can be answered at all.
  #
  # Checked before adding it, not assumed:
  #
  #   pkcheck --action-id org.freedesktop.policykit.exec --allow-user-interaction
  #   -> result=auth_admin
  #      Authorization requires authentication but no agent is available.  (exit 2)
  #
  # polkitd was running and its rules were fine; nothing had ever registered with
  # it. Nixarchy installs no agent, niri starts none, and Noctalia has no polkit
  # code at all (zero hits for the string in the binary). So anything that needed
  # authentication was failing outright instead of prompting -- quietly, because
  # nothing in this session asks for root often enough to notice.
  #
  # hyprpolkitagent rather than polkit-gnome: it is Qt/QML, so it follows the
  # same theme as the Noctalia shell -- and Noctalia themes Qt as well as GTK
  # (templates.toml lists the qt/qt5ct/qt6ct templates), so either toolkit would
  # match; this one is also what niri sessions normally run. The name is
  # misleading -- it is a polkit agent that shares authorship with Hyprland,
  # not a Hyprland plugin, and it needs nothing from the compositor.
  #
  # Launched as a systemd *user* unit, which is what the package ships:
  #
  #   libexec/hyprpolkitagent          the binary, and the only executable --
  #                                     there is no $out/bin, so nothing here
  #                                     is runnable by name and the niri config
  #                                     does not spawn it
  #   lib/systemd/user/hyprpolkitagent.service
  #                                     WantedBy=graphical-session.target,
  #                                     ConditionEnvironment=WAYLAND_DISPLAY
  #   share/dbus-1/services/org.hyprland.hyprpolkitagent.service
  #                                     D-Bus activation onto that unit
  #
  # graphical-session.target is genuinely active in the niri session
  # (`systemctl --user is-active graphical-session.target` -> active), so
  # WantedBy is not a dead symlink there. The D-Bus file is not what starts it:
  # agents register with polkitd by connecting to it, and nothing asks for
  # org.hyprland.hyprpolkitagent by name.
  systemd.packages = [ pkgs.hyprpolkitagent ];
  systemd.user.services.hyprpolkitagent = {
    enable = true;
    wantedBy = [ "graphical-session.target" ];
  };

  # ---------------------------------------------------------------------------
  # Not carried over:
  #
  #   services.desktopManager.gnome.enable = false   and
  #   services.displayManager.gdm.enable = false      (mfv3/display-manager.nix)
  #     No longer true of the greeter. Disabling both would leave the machine
  #     with no display manager, so at the time they were left off on the
  #     grounds that "nixarchy picks the session and the greeter". That first
  #     half no longer holds: the greeter is greetd + Noctalia Greeter, set
  #     above, with nixarchy's SDDM turned off. The GNOME half still holds.
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
