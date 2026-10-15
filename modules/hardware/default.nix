# Machine hardware support: tablet.nix for the V3's tablet bits, probes.nix for
# debug-probe udev rules (probe-rs on the ESP32-C6's built-in USB-JTAG).
{
  imports = [
    ./tablet.nix
    ./probes.nix
  ];
}