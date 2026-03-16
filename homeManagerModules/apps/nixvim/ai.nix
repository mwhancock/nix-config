{ pkgs, ... }:
{
  programs.nixvim = {
    extraPackages = with pkgs; [
      gnumake
    ];

    plugins.avante = {
      enable = true;
      settings = {
        provider = "copilot";
        providers = {
          copilot = {
            model = "gpt-4o";
          };
          ollama = {
            __inherited_from = "openai";
            api_key_name = "";
            endpoint = "http://127.0.0.1:11434/v1";
            model = "qwen2.5-coder:14b";
          };
        };
        mappings = {
          submit = {
            normal = "<CR>";
            insert = "<C-s>";
          };
        };
      };
    };
  };
}
