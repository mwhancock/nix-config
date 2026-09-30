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
{ ... }:
{
  security.sudo.wheelNeedsPassword = false;

  environment.sessionVariables.NH_ELEVATION_STRATEGY = "passwordless";
}
