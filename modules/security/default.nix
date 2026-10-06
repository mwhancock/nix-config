# Rebuilds asked for a password three times, once per privileged call.
#
# nixarchy-apply runs the rebuild inside a systemd *user* unit, which has no
# TTY to prompt on, so it elevates through pkexec -- and nh makes roughly three
# separate privileged calls per switch, each its own polkit transaction. Naming
# the strategy `passwordless` points nh at sudo, and the option below removes
# sudo's credential, so the dialogs stop.
#
# environment.sessionVariables, not environment.variables: the value is read by
# the outer nixarchy-apply process, which is usually a menu-launched desktop
# entry rather than a shell, and only sessionVariables reaches a graphical
# session. nixpkgs builds /etc/pam/environment out of sessionVariables --
# environment.variables only lands in /etc/profile, so a menu would never see it
# and nh would keep reaching for pkexec.
#
# It reaches a *new* session only, which is why the first rebuild after this
# change still prompts three times; the ones after it do not.
#
# Deliberately a weakening of a boundary: anything running as mark can now
# become root without a prompt. Accepted for a single-user desktop where wheel
# membership is the only gate there was anyway.
{ lib, ... }:
{
  security.sudo.wheelNeedsPassword = false;

  environment.sessionVariables.NH_ELEVATION_STRATEGY = "passwordless";

  # ---------------------------------------------------------------------------
  # Fingerprint authentication, for the places that ask.
  #
  # One switch does most of the work, because of a default that is easy to miss:
  # in nixos/modules/security/pam.nix every PAM service's `fprintAuth` defaults
  # to `config.services.fprintd.enable`. So enabling fprintd does not just start
  # a daemon -- it drops `auth sufficient pam_fprintd.so` into *every* generated
  # /etc/pam.d file at once. That is the intent, and it is also why every stack
  # that should not have it is written out as `false` in the table at the bottom.
  #
  # fprintd needs no unit and no ordering: the module puts it in
  # services.dbus.packages, so it is D-Bus activated on first use. Nothing has
  # to be started before the greeter, which matters because the greeter needs it
  # before any session exists.
  #
  # The sensor is the Goodix at 27c6:6092, enumerating as "Goodix USB2.0 MISC".
  # Whether upstream libfprint drives it is not assumed here -- enroll with
  # `fprintd-enroll` and read what it prints. If it says "No devices available",
  # the sensor needs the Touch OEM Drivers build, which is unfree:
  #
  #   services.fprintd.tod = { enable = true; driver = pkgs.libfprint-2-tod1-goodix; };
  #   nixpkgs.config.allowUnfree = true;   # not currently set anywhere in this flake
  services.fprintd.enable = true;

  # ---------------------------------------------------------------------------
  # Howdy: face recognition at the greeter, as a fallback behind the fingerprint.
  #
  # Same shape as the section above, and the same surprise: pam.nix defaults every
  # service's `howdy.enable` to config.services.howdy.enable, so one switch
  # drops pam_howdy into every stack unless it is turned off again by hand.
  services.howdy = {
    enable = true;

    # "sufficient", not nixpkgs' "required". In an auth stack `required` means a
    # failed face match fails the whole stack, so a dark room or a turned-away
    # head would lock you out of a machine whose password you know -- at the
    # greeter, with no keyboard in front of you. `sufficient` makes a match
    # short-circuit and a miss fall through to the fingerprint and then the
    # password.
    control = "sufficient";

    settings = {
      # This machine has two cameras, and they are not interchangeable:
      #
      #   /dev/video0  USB 3-1, Kingcome "USB2.0 FHD UVC WebCam"
      #                1920x1080 MJPG/YUYV -- colour
      #   /dev/video2  the same device's second stream
      #                640x360 8-bit greyscale -- infrared
      #   /dev/video4  USB 1-1, "Hy-QSXGA(8950)", 2592x1944 -- colour, no IR
      #
      # video1/3/5 are the metadata nodes of those three streams, not cameras.
      #
      # nixpkgs' default is /dev/video2, which on this machine is that IR
      # stream. That is not a coincidence worth trusting: with the IR emitter
      # off (nothing on this system turns it on) an IR stream is very dark, and
      # howdy would sit through its whole timeout on every login and then fall
      # through, looking exactly like a camera pointed at the wrong thing.
      # So: the colour stream of the camera that also has the IR one, which is
      # the Hello-style module, and the one that can be moved to IR later if the
      # emitter is ever enabled.
      video.device_path = "/dev/video0";

      # No "Is that you? [y/n]" after a match. Howdy asks by default, through
      # the PAM conversation, which means it waits for a keypress on a terminal
      # -- and the greeter is a GUI with no terminal, so the prompt would either
      # be invisible or hold the login open until it timed out.
      core.no_confirmation = true;
    };
  };

  # ---------------------------------------------------------------------------
  # Which stack gets what. One table, because these are all assignments to
  # security.pam.services and Nix will not let a file define that path twice.
  #
  # login is the greeter: /etc/pam.d/greetd is four lines and its auth line is
  # `auth substack login`, so the stack that matters is `login`, and anything set
  # on `greetd` itself would be a line in a file that immediately hands off.
  #
  # polkit-1 is the stack polkit-agent-helper-1 executes, and that helper is what
  # performs the authentication -- the agent spawns it over
  # polkit-agent-helper.socket and only draws the dialog it reports back. Two
  # consequences worth having written down: fingerprint works with any agent
  # (hyprpolkitagent included, which takes no PAM dependency of its own), and
  # nixpkgs already relaxes the helper's sandbox for it -- polkit.nix adds
  # DeviceAllow=char-usb_device and drops PrivateDevices on
  # polkit-agent-helper@.service when services.fprintd.enable is set, as an
  # overrides.conf drop-in. Without that the helper could not open the sensor,
  # and the prompt would hang and then fall through to the password, which reads
  # as "fingerprint just does not work" rather than as a sandbox denial.
  security.pam.services = lib.mkMerge [
    {
      # The escalation ladder at the greeter: touch, then face, then password.
      # nixpkgs' own module list orders them, fprintd at 11400 and howdy at 11500,
      # both `sufficient` -- so a matched fingerprint ends the stack before howdy
      # ever opens the camera, which is also the cheaper answer to give.
      login = {
        fprintAuth = true;
        howdy.enable = true;
      };
  
      # polkit-1: this is what "other desktop processes that need sudo" actually
      # means -- mounting a disk, NetworkManager, pkexec, nix-monitor. Fingerprint
      # only: a camera prompt for "mount this disk" is worse than the password it
      # would replace, and it would add howdy's four-second timeout to every
      # privileged desktop action.
      polkit-1 = {
        fprintAuth = true;
        howdy.enable = false;
      };
  
      # sudo: both off, and that is not an oversight. wheelNeedsPassword is false
      # above, so sudo already succeeds with no credential at all; a fingerprint
      # there would add a scan timeout to every sudo and change nothing.
      sudo = {
        fprintAuth = false;
        howdy.enable = false;
      };
  
      # sshd: off, for the same reason pam_fprintd is `sufficient` rather than
      # `requisite`. It waits for a scan before returning, and during an SSH login
      # there is nobody at the sensor, so leaving it on would add the timeout to
      # every remote login before falling through to the password. Howdy's own
      # abort_if_ssh would refuse the camera anyway, but not before costing the
      # connection its timeout.
      sshd = {
        fprintAuth = false;
        howdy.enable = false;
      };
  
      # The lock screens keep both, written out rather than left to inherit so the
      # intent survives a change of default. Noctalia's lock screen runs its unlock
      # through omarchy-lock-password, so it accepts a fingerprint or a face for
      # free -- the same "other desktop processes" the fingerprint was wanted for.
      # (nixarchy's own first-run hook would have written these files by sed into
      # /etc/pam.d, which on NixOS are symlinks into the read-only store; the
      # tables here are that same intent, expressed as options.)
      omarchy-lock-password = {
        fprintAuth = true;
        howdy.enable = true;
      };
      omarchy-lock-fingerprint = {
        fprintAuth = true;
        howdy.enable = true;
      };
      swaylock = {
        fprintAuth = true;
        howdy.enable = true;
      };
      vlock = {
        fprintAuth = true;
        howdy.enable = true;
      };
    }

  # And the twenty other stacks that the two switches above quietly filled in.
  #
  # Enabling fprintd and howdy did not touch just the four services named above.
  # Both defaults are global, so pam_fprintd *and* pam_howdy went into every
  # service nixpkgs declares: chfn chpasswd chsh cups groupadd groupdel
  # groupmems groupmod passwd runuser runuser-l su systemd-run0 systemd-user
  # useradd userdel usermod.
  #
  # That is a list of programs that authenticate root for a living and have no
  # business waiting on a camera or a finger. passwd and chfn would ask for a
  # face before letting you change your password; su would sit through howdy's
  # four-second timeout looking for a model belonging to the user being su'd to
  # (there is none -- howdy matches on the authenticating user); cups would scan
  # you per print job; systemd-user and systemd-run0 would add the timeout to
  # anything started under a user session. Both modules are `sufficient`, so
  # nothing here would break -- every one of those commands would still work,
  # a couple of seconds or four later than it should.
  #
  # A second `security.pam.services = ...` in this file would be rejected by Nix:
  # dotted assignments like `security.pam.services.sudo.fprintAuth` are sugar for
  # an attrset that defines this same path, and two definitions of one path in a
  # single attrset are a conflict rather than a merge. Hence one assignment and
  # two elements -- this list is the second element of the mkMerge above, not a
  # definition of its own.
  #
  # genAttrs rather than seventeen copies of the same two lines, so the list of
  # affected programs is readable in one place and stays that way when the next
  # one is added.
  (
    lib.genAttrs [
      "chfn"
      "chpasswd"
      "chsh"
      "cups"
      "groupadd"
      "groupdel"
      "groupmems"
      "groupmod"
      "passwd"
      "runuser"
      "runuser-l"
      "su"
      "systemd-run0"
      "systemd-user"
      "useradd"
      "userdel"
      "usermod"
    ] (_: {
      fprintAuth = false;
      howdy.enable = false;
    })
  )
  ];
}