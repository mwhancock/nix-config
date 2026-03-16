{ pkgs, ... }:
{
  programs.nixvim = {
    extraPackages = with pkgs; [
      gnumake
    ];

    plugins.avante = {
      enable = true;
      settings = {
        provider = "groq";
        providers = {
          groq = {
            __inherited_from = "openai";
            api_key_name = "GROQ_API_KEY";
            endpoint = "https://api.groq.com/openai/v1";
            model = "mixtral-8x7b-32768";
            max_tokens = 4096;
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
