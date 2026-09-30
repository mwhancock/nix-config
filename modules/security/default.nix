# Rebuilds asked for a password three times, once per privileged call.
#
# nixarchy-apply runs the rebuild inside a systemd *user* unit, which has no
# TTY to prompt on, so it elevates through pkexec -- and nh makes roughly three
# separate privileged calls per switch, each its own polkit transaction. Naming
# the strategy `passwordless` points nh at sudo, and the option below removes
# sudo's credential, so the dialogs stop.
#
# environment.variables rather than home.sessionVariables because the value is
# read by the outer nixarchy-apply process, which is usually a menu-launched
# desktop entry rather than a shell. nixpkgs writes these through pam_env, so
# they do reach a graphical session -- but only a *new* one, which is why the
# first rebuild after this change still prompts three times.
#
# Deliberately a weakening of a boundary: anything running as mark can now
# become root without a prompt. Accepted for a single-user desktop where wheel
# membership is the only gate there was anyway.
{ ... }:
{
  security.sudo.wheelNeedsPassword = false;

  environment.variables.NH_ELEVATION_STRATEGY = "passwordless";
}
