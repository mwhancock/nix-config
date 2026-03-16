{ pkgs, ... }:
{
  programs.nixvim = {
    extraPackages = with pkgs; [
      gnumake
    ];

    plugins.avante = {
      enable = true;
      settings = {
        provider = "gemini";
        providers = {
          gemini = {
            api_key_name = "GEMINI_API_KEY";
            model = "gemini-2.5-pro";
            timeout = 30000;
            temperature = 0;
            max_tokens = 8096;
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
