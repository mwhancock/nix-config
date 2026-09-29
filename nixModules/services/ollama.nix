{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    loadModels = [ "llama3.1" "qwen2.5-coder:14b" "qwen2.5-coder:1.5b" "qwen2.5-coder:7b" ];
  };
}
