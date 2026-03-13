{ inputs, ... }:
{
  imports = [ inputs.dsearch.homeModules.default ];

  programs.dsearch = {
    enable = true;
  };
}
