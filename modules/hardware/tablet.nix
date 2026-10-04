# Tablet hardware: the accelerometer, the panel backlight, and the DDC path.
#
# All of this is specific to the Minisforum V3 (MB8) -- 8840U, Hawk Point, AMI
# BIOS. The DSDT patch in particular is a dump of THIS machine's firmware, so
# this module belongs to the host, not to a generic "tablets" module; the
# hwdb rule below is keyed on this machine's DMI for the same reason.
#
# ---------------------------------------------------------------------------
# 1. Why an ACPI table override instead of a kernel patch
# ---------------------------------------------------------------------------
# The LSM6DS3TRC accelerometer is declared in the DSDT as
# \_SB.I2CD.STS with the hardware ID EisaId ("SMOCF05"), which no in-tree
# driver claims. The device enumerates (i2c-SMOCF05:00 exists, unbound) and
# then nothing probes it, so there is no IIO accelerometer at all.
#
# The obvious fix is to add SMOCF05 to the of/acpi table of
# drivers/iio/imu/st_lsm6dsx/st_lsm6dsx_i2c.c, which is a boot.kernelPatches
# job: a full local kernel rebuild, no binary cache, and a new kernel on every
# upgrade.
#
# Instead the HID is renamed in the DSDT. "SMO8B30" is already in that driver
# table in stock upstream source, mapped to ST_LSM6DS3TRC_ID, so renaming the
# ACPI device in ASL is enough for the shipped driver to bind. Same result, no
# rebuild, no kernel to carry.
#
# The patched table is delivered through the kernel's initrd override:
# acpi_table_upgrade() (drivers/acpi/tables.c) walks the initramfs cpio for
# entries under kernel/firmware/acpi/, validates signature, length and
# checksum, and installs the table before ACPI is parsed. CONFIG_ACPI_TABLE_
# UPGRADE is y in this kernel (x86 selects ARCH_HAS_ACPI_TABLE_UPGRADE and it
# defaults to y) and /sys/kernel/security/lockdown does not exist on this
# machine, so nothing refuses the override.
#
# The override is a whole-table replacement, not a patch: whatever a future
# BIOS ships is superseded by hosts/nixos/acpi/dsdt.dsl. A BIOS update that
# changes the DSDT therefore wants a fresh dump of that file. If the table is
# wrong the kernel refuses it -- wrong signature, length or checksum all print
# "ACPI OVERRIDE:" in dmesg and the table is skipped -- so the failure mode is
# no accelerometer, not a broken ACPI tree.
#
# A successful override is loud and slightly rude: the kernel taints itself
# with TAINT_OVERRIDDEN_ACPI_TABLE and warns. That is the same trade-off the
# Arch fix for this machine makes, and it is the price of not rebuilding.
#
# ---------------------------------------------------------------------------
# 2. Why boot.initrd.prepend and not boot.initrd.extraFiles
# ---------------------------------------------------------------------------
# boot.initrd.extraFiles can only symlink: make-initrd.sh does
# `ln -s $object root/$symlink` for every entry. The kernel then finds a cpio
# entry whose payload is the symlink target string, not the table, and
# rejects it on the length check. A real file has to be in the cpio, and
# boot.initrd.prepend is the option that takes uncompressed cpio archives.
# The kernel unpacks concatenated segments and handles a plain newc archive
# ahead of the compressed initramfs, which is the same trick mkinitcpio's
# early-cpio uses.
#
# After a rebuild, before a reboot, the table is not in the running kernel.
# The accelerometer shows up on the next boot, not the next switch.
{ config, lib, pkgs, ... }:

let
  acpiTables = pkgs.runCommand "minisforum-v3-acpi-tables"
    {
      nativeBuildInputs = [ pkgs.acpica-tools pkgs.cpio ];
    } ''
    mkdir -p tables kernel/firmware/acpi/tables
    iasl -tc -p tables/DSDT ${../../hosts/nixos/acpi/dsdt.dsl}
    install -m 0444 tables/DSDT.aml kernel/firmware/acpi/tables/DSDT

    # The cpio names must be relative and must start with
    # kernel/firmware/acpi/ -- that string is the prefix acpi_table_upgrade()
    # hands to find_cpio_data(). So find has to run from the root of this
    # directory, not from inside kernel/, or the entries come out as
    # firmware/acpi/... and the kernel never looks at them.
    # --reproducible and -R 0:0 keep the bytes stable so this derivation is
    # not rebuilt on every flake evaluation.
    find kernel -print0 \
      | cpio --null -o -H newc --quiet --reproducible -R 0:0 > $out
  '';
in
{
  boot.initrd.prepend = [ (toString acpiTables) ];

  # -------------------------------------------------------------------------
  # The panel is mounted 180 degrees off relative to the sensor's axes, so the
  # accelerometer's raw readings have to be flipped before auto-rotation can
  # classify them. The kernel's own sysfs mount_matrix attribute is root-only
  # and the st_lsm6dsx driver does not set one, so the correction goes in as a
  # udev property instead: iio-sensor-proxy reads ACCEL_MOUNT_MATRIX from the
  # udev database before it looks at sysfs (accel-mount-matrix.c in that
  # source), which is why systemd ships hwdb keys of this shape for hundreds of
  # other machines.
  #
  # All three axes are negated, and that is deliberate even though it leaves the
  # proxy's tilt labels reading backwards. Measured on this machine, raw values
  # alongside what the proxy then reported:
  #
  #   no matrix at all, flat face up     raw ( 0.13,  0.05, +9.90)
  #     -> tilt "face-up", but a plain tilt of the top edge away reads Z about
  #        -3.6 with Y near +9.4, which the proxy calls "bottom-up" and iio-niri
  #        duly rotates the screen to 180. Tilting the panel should never do that.
  #   all three negated, flat face up   raw ( 0.13,  0.05, +9.90)
  #     -> tilt "face-down", which is wrong, but the same tilt now lands on
  #        "normal" and the screen stays put, and only a real sideways hold
  #        reaches left-up or right-up and rotates to 90 or 270.
  #
  # So the Z inversion is what keeps ordinary tilting from flipping the display,
  # and the Y inversion only ever affects the AccelerometerTilt label. Those
  # labels are cosmetic here: nothing user-facing on this machine reads them,
  # iio-niri acts on AccelerometerOrientation alone. Correct rotation behavior
  # is worth an upside-down tilt string.
  #
  # The key is the one systemd's 60-sensor.rules builds for the IIO device
  # (60-sensor.rules:22): the modalias of its nearest ancestor with a modalias,
  # which is the i2c client, so
  # sensor:modalias:acpi:SMO8B30:SMO8B30:<dmi-modalias>.
  # iio-sensor-proxy opens the IIO character device and looks the mount matrix
  # up in the udev database for that device, so this is the record that has to
  # resolve.
  #
  # The same rules file also imports a HID-shaped key for the input event node
  # (60-sensor.rules:29), sensor:modalias:acpi:SMO8B30:<dmi-modalias>. That one
  # is deliberately absent: with both records in the same file it did not
  # resolve against systemd-hwdb query, and nothing here reads the property off
  # the event node.
  #
  # SMO8B30 is the HID this configuration's DSDT patch installs, and
  # svnMicroComputer / pnV3 is this machine's DMI, copied from
  # /sys/class/dmi/id/modalias. systemd's own hwdb has a SMO8B30 entry too, for
  # the Lenovo IdeaPad Duet, which does not match here.
  #
  # Checked without booting by compiling the configuration's hwdb and querying
  # it with the exact string udev will build:
  #   systemd-hwdb query "sensor:modalias:acpi:SMO8B30:SMO8B30:$(cat /sys/class/dmi/id/modalias)"
  #
  # Verify on the running machine with:
  #   udevadm info --query=property --path=/sys/bus/iio/devices/iio:deviceN \
  #     | grep ACCEL_MOUNT_MATRIX
  # Note that a hwdb or rules change only lands on an existing device once udev
  # replays it, so after a rebuild that changes this:
  #   sudo udevadm trigger --subsystem-match=iio --action=add
  # Otherwise the property keeps its old value until the next boot.
  # -------------------------------------------------------------------------
  services.udev.extraHwdb = ''
    sensor:modalias:acpi:SMO8B30:*:dmi:*:svnMicroComputer*:pnV3:*
     ACCEL_MOUNT_MATRIX=-1, 0, 0; 0, -1, 0; 0, 0, -1
  '';

  # -------------------------------------------------------------------------
  # iio-sensor-proxy turns the IIO accelerometer into an
  # org.freedesktop.Sensors service; iio-niri listens to it and drives niri's
  # output transforms. Enabling the module also turns on hardware.sensor.iio,
  # so the proxy comes with it and its udev rules come with the proxy.
  # Only the internal panel rotates; DP-3 is a desk monitor.
  # -------------------------------------------------------------------------
  services.iio-niri = {
    enable = true;
    extraArgs = [
      "--monitor"
      "eDP-1"
    ];
  };

  # -------------------------------------------------------------------------
  # The panel's brightness attribute is root:root 0644 and mark is not in
  # video, so Noctalia cannot write the eDP-1 brightness and falls back to
  # nothing. Giving the attribute to the video group is the arrangement every
  # distribution ships; the rule runs on add, and the attribute is recreated
  # whenever amdgpu re-probes, so the mode has to be reapplied each time too.
  #
  # DDC over i2c-17 needs no rule of its own: services.udev.packages already
  # carries i2c-udev-rules, which tags i2c adapters uaccess, and that is where
  # the ACL on /dev/i2c-17 comes from.
  # -------------------------------------------------------------------------
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl1", \
      RUN+="/bin/sh -c 'chgrp video /sys/class/backlight/%k/brightness; chmod g+w /sys/class/backlight/%k/brightness'"

    # Force iio-sensor-proxy onto the polling path for this accelerometer.
    #
    # 80-iio-sensor-proxy.rules tags any IIO device that has both raw accel
    # attributes and scan_elements as "iio-poll-accel iio-buffer-accel", and the
    # proxy prefers the buffered one. st_lsm6dsx does expose scan_elements, so
    # that is what it picks here -- but this machine's sensor has no IIO trigger
    # at all (no iio:device*/trigger directory, and the lsm6dsx IRQ on
    # IR-IO-APIC 107 stays at a fixed count), so the buffered path enables
    # buffer0, waits 0.5s for data that can never arrive, and gives up:
    #   Could not find trigger name associated with .../iio:device1
    #   Buffer '/dev/iio:device1' did not have data within 0.5s
    # Leaving the buffer enabled then makes every unbuffered read fail with
    # EBUSY, so the polling fallback is locked out too. The visible symptom is
    # AccelerometerOrientation frozen at "normal", which iio-niri correctly
    # ignores -- no orientation change, no rotation, ever.
    #
    # Assigning (not appending) the property leaves only the polling type, which
    # reads in_accel_x/y/z_raw directly. A 1 g reading on Z while flat confirms
  # the values are real. Ordering is purely lexical -- udev merges every rules
  # file it finds and this configuration keeps them all in one directory, where
  # services.udev.extraRules lands in 99-local.rules, after 80-.
    SUBSYSTEM=="iio", ATTR{name}=="lsm6ds3tr-c_accel", \
      ENV{IIO_SENSOR_PROXY_TYPE}="iio-poll-accel"
  '';

  users.users.mark.extraGroups = [ "video" ];
}