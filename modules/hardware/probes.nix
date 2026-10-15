# Debug-probe access: let the desktop user talk to the ESP32-C6's built-in
# USB-JTAG/serial unit without root.
#
# The symptom this exists to fix is a `cargo run` in an esp-generate project:
#
#   Error: Failed to open probe: Failed to open the debug probe.
#   Caused by: ... permission denied (errno 13)
#
# probe-rs -- the cargo `runner` esp-generate writes into .cargo/config.toml --
# opens the raw USB device node. For this board that is
# /dev/bus/usb/005/013, and udev leaves it root:root 0644. Serial flashing was
# never affected because espflash opens /dev/ttyACM0, which is root:dialout
# 0660 and `dialout` is already in mark's extraGroups. That asymmetry is the
# whole reason an older, espflash-based project flashed and monitored fine and
# this one does not -- not the project, the tool.
#
# Granting group `dialout` on the USB node rather than inventing `plugdev`
# keeps this to a udev rule alone: no new group, and no re-login for a
# membership change to take effect.
#
# 303a is Espressif's USB vendor id. 1001 is the "USB JTAG/serial debug unit"
# this C6 enumerates; 1002 is the USB Serial/JTAG variant other ESP32 parts
# use. The match is on the usb_device node itself (SUBSYSTEM=="usb"), not on
# its tty interface, because that is the node probe-rs opens.
{
  services.udev.extraRules = ''
    # Espressif USB JTAG/serial debug unit (ESP32-C6 and friends), for probe-rs.
    SUBSYSTEM=="usb", ATTR{idVendor}=="303a", ATTR{idProduct}=="1001", MODE="0660", GROUP="dialout"
    SUBSYSTEM=="usb", ATTR{idVendor}=="303a", ATTR{idProduct}=="1002", MODE="0660", GROUP="dialout"
  '';
}
