{ lib
, flutterPackages
, fetchFromGitHub
, gst_all_1
, libunwind
, orc
, webkitgtk_4_1
, autoPatchelfHook
, libxmu
, jdk
, zlib
, runCommand
, rustPlatform
, pkg-config
, at-spi2-atk
, gdk-pixbuf
, cairo
, gtk3
, writeText
, stdenv
}:

let
  zlib-root = runCommand "zlib-root" { } ''
    mkdir $out
    ln -s ${zlib.dev}/include $out/include
    ln -s ${zlib}/lib $out/lib
  '';

  version = "1.37.1";

  src = fetchFromGitHub {
    owner = "saber-notes";
    repo = "saber";
    tag = "v${version}";
    sha256 = "1dky835gpx0vicczpwc4nwvplvrk60i24i8jvqrhv50phaqlvpss";
  };
in
flutterPackages.stable.buildFlutterApplication {
  pname = "saber";
  inherit version src;

  # Patches applied on top of upstream Saber:
  #   - saber-cursor.patch: hides the system mouse cursor over the canvas and
  #     draws a small dot that follows the stylus/mouse instead.
  #   - saber-eraser.patch: switches to the Eraser tool at the start of a draw
  #     gesture when the stylus button is pressed, which also covers styluses
  #     whose rear eraser is reported without a preceding hover event.
  #   - saber-impeller.patch: disables Flutter's Impeller renderer on Linux,
  #     which otherwise makes strokes look aliased/rough on this hardware.
  #   - saber-bg-scrollbar.patch: adds a visible scrollbar to the background
  #     pattern selector so the additional patterns (including Dots) are
  #     discoverable.
  patches = [
    ./saber-cursor.patch
    ./saber-eraser.patch
    ./saber-impeller.patch
    ./saber-bg-scrollbar.patch
  ];

  pubspecLock = lib.importJSON ./saber-pubspec.lock.json;
  gitHashes = lib.importJSON ./saber-git-hashes.json;

  # super_native_extensions 0.10.0-dev.2 uses native_toolchain_rust which tries
  # to invoke rustup during the Flutter build. That doesn't work in a sandboxed
  # Nix build, so replace its build hook with one that copies a prebuilt Rust
  # library built here.
  customSourceBuilders = {
    super_native_extensions =
      { version, src, ... }:
      let
        rustDep = rustPlatform.buildRustPackage {
          pname = "super_native_extensions-rs";
          inherit version src;

          unpackPhase = ''
            runHook preUnpack
            if [ -d $src/super_native_extensions ]; then
              cp -r $src/super_native_extensions ${src.name}
            else
              cp -r $src ${src.name}
            fi
            chmod -R u+w -- "$sourceRoot"
            runHook postUnpack
          '';

          sourceRoot = "${src.name}/rust";

          cargoHash =
            rec {
              _0_9_1 = _0_9_0-dev_6;
              _0_9_0-dev_6 = "sha256-1yJIbBxScmkCwy/e+/z2cYA8qQBfT0yoIBmOSPVd4h4=";
              _0_9_0-dev_5 = _0_8_22;
              _0_9_0-dev_3 = _0_8_22;
              _0_8_22 = "sha256-gYYoC3bGJrYY1uUHfqMv6pp4SK+P9fRoBsLtf34rsCg=";
              _0_8_24 = _0_8_22;
              _0_8_21 = _0_8_22;
              _0_8_20 = _0_8_22;
              _0_8_19 = _0_8_22;
              _0_8_18 = _0_8_22;
              _0_8_17 = _0_8_22;
              _0_10_0-dev_2 = "sha256-PbmAtRQpUJjWTsIVao87ywNCAGiZCB2Np6Ig7yh6c5Y=";
            }
            .${"_" + (lib.replaceStrings [ "." ] [ "_" ] version)} or (throw ''
              Unsupported version of pub 'super_native_extensions': '${version}'
              Please add cargoHash to the custom source builder in saber.nix.
            '');

          nativeBuildInputs = [ pkg-config ];
          buildInputs = [ at-spi2-atk gdk-pixbuf cairo gtk3 ];
          passthru.libraryPath = "lib/libsuper_native_extensions_native.so";
        };

        prebuiltHook = writeText "super_native_extensions-build.dart" ''
          import 'dart:io';
          import 'package:code_assets/code_assets.dart';
          import 'package:hooks/hooks.dart';

          void main(List<String> args) async {
            await build(args, (input, output) async {
              if (!input.config.buildCodeAssets) return;

              const assetName = 'super_native_extensions_native';
              final sourcePath = Uri.file('${rustDep}/${rustDep.passthru.libraryPath}');
              final assetPath = input.outputDirectory.resolve('lib$assetName.so');

              await Directory.fromUri(assetPath.resolve('..')).create(recursive: true);
              await File.fromUri(sourcePath).copy(assetPath.toFilePath());

              output.dependencies.add(sourcePath);
              output.assets.code.add(
                CodeAsset(
                  package: input.packageName,
                  name: assetName,
                  file: assetPath,
                  linkMode: DynamicLoadingBundled(),
                ),
              );
            });
          }
        '';
      in
      stdenv.mkDerivation {
        pname = "super_native_extensions";
        inherit version src;
        inherit (src) passthru;
        installPhase = ''
          runHook preInstall
          cp -r "$src" "$out"
          chmod -R u+w "$out"
          pushd "$out"
          cp ${prebuiltHook} hook/build.dart
          if ! grep -q "code_assets:" pubspec.yaml; then
            sed -i '/^dependencies:/a\  code_assets: ^0.15.0' pubspec.yaml
          fi
          popd
          runHook postInstall
        '';
      };
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    libunwind
    orc
    webkitgtk_4_1
    libxmu
    jdk
  ];

  postPatch = ''
    patchShebangs patches/pre/remove_proprietary_dependencies.sh patches/pre/remove_permission_handler.sh
    patches/pre/remove_proprietary_dependencies.sh
    patches/pre/remove_permission_handler.sh
  '';

  flutterBuildFlags = [ "--dart-define=DIRTY=false" ];

  env.ZLIB_ROOT = zlib-root;

  postInstall = ''
    install -Dm0644 flatpak/com.adilhanney.saber.desktop $out/share/applications/saber.desktop
    install -Dm0644 assets/icon/icon.svg $out/share/icons/hicolor/scalable/apps/com.adilhanney.saber.svg
    install -Dm0644 flatpak/com.adilhanney.saber.metainfo.xml -t $out/share/metainfo
  '';

  preFixup = ''
    patchelf --shrink-rpath --allowed-rpath-prefixes "$NIX_STORE" $out/app/saber/lib/lib*.so
  '';

  meta = {
    description = "Cross-platform open-source app built for handwriting";
    homepage = "https://github.com/saber-notes/saber";
    mainProgram = "saber";
    license = lib.licenses.gpl3Plus;
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
