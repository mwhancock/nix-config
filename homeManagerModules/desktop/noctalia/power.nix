{ ... }:
{
  programs.noctalia-shell.settings = {
    idle = {
      enabled = false;
      screenOffTimeout = 600;
      lockTimeout = 660;
      suspendTimeout = 1800;
      fadeDuration = 5;
      screenOffCommand = "";
      lockCommand = "";
      suspendCommand = "";
      resumeScreenOffCommand = "";
      resumeLockCommand = "";
      resumeSuspendCommand = "";
      customCommands = "[]";
    };

  };
}
