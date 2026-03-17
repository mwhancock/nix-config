{ ... }:
{
  programs.noctalia-shell.settings = {
    audio = {
      volumeStep = 5;
      volumeOverdrive = false;
      spectrumFrameRate = 30;
      visualizerType = "linear";
      mprisBlacklist = [ ];
      preferredPlayer = "";
      volumeFeedback = false;
      volumeFeedbackSoundFile = "";
    };
  };
}
