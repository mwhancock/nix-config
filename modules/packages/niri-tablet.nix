# niri built with the niri-tablet touchscreen gesture patchset.
#
# Why this exists at all: upstream niri has no touchscreen gestures. Its own
# README, shipped in the doc output of the niri it patches, says so --
#
#   **Input devices**: niri supports tablets, touchpads, and touchscreens.
#   We have touchpad gestures, but no touchscreen gestures yet.
#
# and `niri validate` on stock niri rejects show-touch-points, touchscreen-swipe
# and touchscreen-edge-swipe as unknown nodes -- three errors, and niri refuses
# to start at all on a config that does not parse.
#
# GGEZUS/niri-tablet is not a fork. It is a patchset: 20 patches against
# upstream niri, plus an Arch PKGBUILD, and no flake.nix. So it is consumed as a
# `flake = false` input and applied to pkgs.niri here.
#
# Why this applies cleanly rather than being fought with:
#
#   The PKGBUILD pins pkgver=26.04.20.gef77de00 -- niri 26.04 plus 20 commits
#   -- and this flake's pinned nixpkgs carries niri 26.04. Same base, so the
#   series applies. Verified by unpacking the nixpkgs niri source and running
#   the whole series with `patch -p1` in order: all 20 apply, no fuzz, no rejects.
#
#   The patches are `git format-patch` output, which `patch -p1` handles by
#   skipping the mail headers -- so this does NOT need git in nativeBuildInputs
#   and does NOT need a `git init` dance in postPatch. That matters only because
#   it is the simpler thing; correctness does not rest on it.
#
#   No patch touches Cargo.toml or Cargo.lock. Checked, not assumed: it means
#   cargoHash stays valid and the prebuilt cargoDeps vendor directory from the
#   stock niri derivation is reused as-is. If a future revision of the patchset
#   does add a dependency, the build will fail on the cargo vendor hash rather
#   than silently producing something different.
#
# What it costs: a full Rust build of niri on this machine rather than a
# 12MB binary download, and it is rebuilt whenever the nixpkgs niri version
# moves. That is the price of upstream not shipping the feature, and it is only
# worth paying for the machine that has a touchscreen.
#
# Consumers: modules/desktop/default.nix, via programs.niri.package.
{ lib, niri, niri-tablet }:

let
  patches = lib.filter (name: lib.hasSuffix ".patch" name)
    (lib.attrNames (lib.readDir (niri-tablet + "/pkg")));
in
# `if`/`throw`, not `assert`: Nix's assert takes no message, and writing one
# anyway parses as an application -- `assert (cond) "msg";` calls the Boolean
# `true`, and without the parens `assert cond == 20 "msg";` calls the integer
# 20, because function application binds tighter than `==`. Both were tried; the
# errors are in the git history of this file if they are ever needed again.
if builtins.length patches == 20 then
  niri.overrideAttrs (old: {
    version = "${niri.version}-niri-tablet";
    # Silences the "overriding version" warning. The version genuinely is a
    # different package -- stock 26.04 cannot parse this configuration -- so the
    # suffix is load-bearing, not cosmetic. It also keeps the store path distinct
    # from stock niri's, so the two can never be confused in a profile.
    __intentionallyOverridingVersion = true;

    # The checkPhase runs and passes -- 233 tests, including the gesture tests
    # the patchset adds -- but installCheckPhase then fails, because
    # versionCheckHook compares the derivation's version against what the binary
    # prints and the binary honestly reports "niri 26.04 (Nixpkgs)". That string
    # comes from Cargo plus NIRI_BUILD_COMMIT, neither of which the patchset
    # changes. Only the Nix derivation knows about the patchset.
    #
    # So the version is renamed but the binary's is not, and the hook cannot
    # reconcile them. Disabling installCheckPhase is the honest fix; faking
    # NIRI_BUILD_COMMIT to match would put a lie in `niri --version` that anyone
    # reading bug reports would then have to unpick.
    doInstallCheck = false;

    # Sorted so the order does not depend on how readDir happened to sort it. The
    # filenames are zero-padded (0001..0020), so lexicographic is also numeric --
    # and the series is order-dependent by nature: each patch builds on the last.
    patches = old.patches ++ map (name: niri-tablet + "/pkg/" + name) (lib.sort (a: b: a < b) patches);
  })
else
  throw "niri-tablet patchset: expected 20 patches under ${niri-tablet}/pkg, found ${toString (builtins.length patches)}. The series was rebased or truncated upstream, so re-read it before trusting this build."