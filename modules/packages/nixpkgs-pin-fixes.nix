# Local workarounds for packages that do not build on the current nixpkgs pin.
#
# Each entry names the upstream issue and fix, and is guarded so it becomes a
# no-op once the pin carries that fix. Delete the entry (and this file, when it
# is empty) rather than letting the workaround live forever.
{ lib, ... }:

{
  # gtk2 (attribute `gtk+`) is marked broken on this pin while its removal is
  # staged for NixOS 27.05 (NixOS/nixpkgs#410814). onlyoffice-desktopeditors
  # still lists gtk2 in buildInputs -- it is one of the prebuilt .deb's runtime
  # libraries -- so the whole system closure refuses to evaluate:
  #
  #   error: Refusing to evaluate package 'gtk+-2.24.33' ... because it has problems:
  #   - broken: gtk2 will be removed ...
  #
  # Nothing in this configuration can migrate onlyoffice off gtk2, and dropping
  # the package would be a bigger change than the warning is worth. Warn rather
  # than fail, so evaluation succeeds and the notice keeps appearing at every
  # rebuild until the pin carries an onlyoffice that has dropped the dependency.
  # Delete this block then.
  #
  # mkDefault is load-bearing. nixpkgs.config is merged by a custom type that
  # discards every definition below the highest priority, so a plain
  # `nixpkgs.config = { ... }` here would silently drop nixarchy's own
  # `lib.mkDefault { allowUnfree = true; }` and every unfree app (jocalsend,
  # the browsers) would start failing licence checks. At the same priority the
  # two definitions are merged instead.
  nixpkgs.config = lib.mkDefault {
    problems.handlers."gtk+".broken = "warn";

    # pybars3 0.9.7 is flagged for CVE-2026-119716 (code injection through
    # bracketed path segments in a Handlebars template). It reaches the closure
    # only through kikit, which uses it for panelization templates it reads
    # from the user's own config -- exploiting the CVE needs a template from an
    # untrusted source, and there is no fixed pybars3 release to move to.
    # Permit that one derivation rather than disabling kikit; remove the entry
    # once nixpkgs carries a fix or kikit drops the dependency.
    # pypdf2 3.0.1 is flagged for CVE-2026-27024, -27025, -27628, -27888,
    # -28351 and -33699 (malicious PDFs crash or execute code in the parser).
    # It reaches the closure only through odoo19's buildInputs, and pypdf2 is
    # abandoned upstream in favour of pypdf with no fixed release to move to,
    # so the version cannot be bumped here. Odoo only parses PDFs uploaded to
    # the user's own instance, which is the same trust boundary as kikit above.
    # Remove the entry once nixpkgs carries an odoo that uses pypdf.
    permittedInsecurePackages = [
      "python3.14-pybars3-0.9.7"
      "python3.12-pypdf2-3.0.1"
    ];
  };

  nixpkgs.overlays = [
    (
      final: prev:
      let
        # Shared by both Python package sets: the system closure reaches
        # pyopenjtalk-plus through python3Packages (piper-tts, calibre), and
        # python314Packages is a separate attribute set even though python3 is
        # 3.14 here, so fixing one does not fix the other.
        fixPyopenjtalk = super: super.pyopenjtalk-plus.overrideAttrs (old:
          lib.optionalAttrs
            (!(builtins.any (p: (p.name or "") == "fix-cython-3.3.0.patch") (old.patches or [ ]))) {
            patches = (old.patches or [ ]) ++ [
              (prev.fetchpatch {
                name = "fix-cython-3.3.0.patch";
                url = "https://github.com/tsukumijima/pyopenjtalk-plus/commit/90b644f9e9d397882e6eafe4dcd1843a4fde6a63.patch";
                includes = [ "tests/test_frontend.py" ];
                hash = "sha256-Jb7T/bRUHxqwBLwV6xYC/teaFHm5GmqJxA7sCX+oiNI=";
              })
            ];
          });
      in
      {
        # gearlever does not build on the current pin.
        #
        # Since Python packages are built with __structuredAttrs, makeWrapperArgs
        # is handed to wrapPythonPrograms as a real Bash array rather than a
        # string that gets word-split and expanded. gearlever's expression still
        # passes the two old-style elements
        #
        #   "\${gappsWrapperArgs[@]}"          -- meant to be expanded at fixup time
        #   "--prefix PATH : /nix/store/..."   -- several arguments packed in one
        #
        # so the wrapper is generated with the former as a literal argument and
        # the latter unsplit. makeCWrapper rejects both, and the build dies in
        # fixupPhase:
        #
        #   makeCWrapper: Unknown argument ${gappsWrapperArgs[@]}
        #
        # NixOS/nixpkgs#576910, fixed by NixOS/nixpkgs#575801. Apply the same
        # shape without copying gearlever's dependency list: expand
        # gappsWrapperArgs from preFixup, and split the packed --prefix back
        # into one list element per argument.
        gearlever = prev.gearlever.overrideAttrs (old:
          let
            gappsArg = "\${gappsWrapperArgs[@]}";
          in
          lib.optionalAttrs (builtins.elem gappsArg old.makeWrapperArgs) {
            preFixup = (old.preFixup or "") + ''
              makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
            '';

            makeWrapperArgs = builtins.concatMap (arg:
              if arg == gappsArg then [ ]
              else
                let
                  packed = builtins.match "--prefix PATH : (.*)" arg;
                in
                if packed == null then
                  [ arg ]
                else
                  [ "--prefix" "PATH" ":" (builtins.head packed) ]
            ) old.makeWrapperArgs;
          });

        # udiskie's test_is_valid caches a password with a one-second keyring
        # timeout, then asserts the cache is still non-empty after a delete and
        # a re-add:
        #
        #   AssertionError: <udiskie.cache.PasswordCache object ...> is not true
        #
        # A whole-machine rebuild puts this test on the same cores as niri's
        # and quickshell's check phases, and if more than a second passes
        # between the write and the check the key has expired by design. The
        # same sequence passes when run by hand on this kernel, so it is a
        # scheduling flake, not a keyutils or kernel change. Disable that one
        # test and keep the other thirteen. nixarchy adds its own (stale,
        # harmless) test_list_keys entry on top; this is the test that fails.
        # Drop the entry once the test has a timeout that survives a parallel
        # build.
        udiskie = prev.udiskie.overridePythonAttrs (old: {
          disabledTests = (old.disabledTests or [ ]) ++ [ "test_is_valid" ];
        });

        # pyopenjtalk-plus fails one test under Cython 3.3: the generated type
        # check raises "Expected str, got int" before the package's own
        # "must be str" check, so the test's regex no longer matches.
        #
        # NixOS/nixpkgs#576442, fixed by NixOS/nixpkgs#576063, which carries the
        # upstream commit below limited to tests/test_frontend.py. Match on the
        # patch name so a pin that already has it is left alone.
        python3Packages = prev.python3Packages.overrideScope (self: super: {
          pyopenjtalk-plus = fixPyopenjtalk super;
        });

        python314Packages = prev.python314Packages.overrideScope (self: super: {
          pyopenjtalk-plus = fixPyopenjtalk super;
        });

        # calibre's build test does `import speechd` and fails with
        # ModuleNotFoundError because speech-dispatcher's Python bindings are
        # not built. With strictDeps the interpreter sits in buildInputs, so it
        # is not on PATH while configure looks for it.
        #
        # NixOS/nixpkgs#576062 moves python3Packages.python from buildInputs to
        # nativeBuildInputs for the same reason. Guarded on it still being in
        # buildInputs so it is a no-op once the pin carries the fix.
        speechd = prev.speechd.overrideAttrs (old:
          lib.optionalAttrs (builtins.elem prev.python3Packages.python old.buildInputs) {
            nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ prev.python3Packages.python ];
            buildInputs = lib.remove prev.python3Packages.python old.buildInputs;
          });
      }
    )
  ];
}
