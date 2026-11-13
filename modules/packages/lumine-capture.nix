# LumineCapture: fast Wayland screenshot tool with annotations and OCR.
# Not in nixpkgs, so built from source from the flake's git input.
#
# The build's one non-obvious piece is ONNX Runtime. oar-ocr enables ort's
# `download-binaries` feature, whose build script fetches prebuilt ORT
# binaries from the network -- which the Nix sandbox does not have. Setting
# ORT_LIB_LOCATION makes that script link against a given ORT install
# instead of downloading, so it points at nixpkgs' onnxruntime. That copy is
# 1.27, which matches the api-27 feature set `ort` defaults to, so the
# symbols the bindings expect are present. ORT_PREFER_DYNAMIC_LINK=1 keeps
# it from hunting for a static libonnxruntime.a, which nixpkgs does not ship.
#
# OCR models themselves are downloaded at first use by the app, at runtime;
# that is unaffected by any of this.
{ lib
, stdenv
, rustPlatform
, pkg-config
, libclang
, openssl
, wayland
, pipewire
, libxkbcommon
, onnxruntime
, oniguruma
, lumine-capture
}:

rustPlatform.buildRustPackage {
  pname = "lumine-capture";
  version = "0.3.0";

  src = lumine-capture;

  cargoLock.lockFile = "${lumine-capture}/Cargo.lock";

  nativeBuildInputs = [
    pkg-config
    libclang.lib
  ];

  buildInputs = [
    openssl
    wayland
    pipewire
    libxkbcommon
    onnxruntime
    # onig_sys (via tokenizers) looks for oniguruma through pkg-config. The
    # header and the .pc file both come from this package's dev output, so
    # adding it to buildInputs is enough for pkg-config to find both.
    oniguruma
  ];

  env = {
    ORT_LIB_LOCATION = "${lib.getLib onnxruntime}/lib";
    ORT_PREFER_DYNAMIC_LINK = "1";

    # pipewire-sys/libspa-sys generate bindings with bindgen, and libclang on
    # NixOS does not search glibc's include directory on its own -- without
    # this the build dies on "'inttypes.h' file not found".
    #
    # Both paths are interpolated rather than written out literally, so they
    # carry a store-path context and end up in the derivation's closure. A
    # literal path is not mounted inside the build sandbox, and the build
    # fails exactly as above.
    LIBCLANG_PATH = "${libclang.lib}/lib";
    BINDGEN_EXTRA_CLANG_ARGS = "-isystem ${stdenv.cc.libc.dev}/include -isystem ${libclang.lib}/lib/clang/${lib.versions.major libclang.version}/include";
  };

  doCheck = false;

  postInstall = ''
    if [ -x "$out/bin/lumine-capture" ]; then
      substituteInPlace assets/lumine-capture.desktop \
        --replace-fail '/usr/bin/lumine-capture' "$out/bin/lumine-capture"
      install -Dm644 assets/lumine-capture.desktop -t "$out/share/applications"
    fi
    mkdir -p "$out/share/icons"
    cp -r assets/hicolor "$out/share/icons/"
  '';

  meta = {
    description = "Fast, lightweight Wayland screenshot tool with annotations and OCR";
    homepage = "https://github.com/Netflate/LumineCapture";
    license = with lib.licenses; [ mit asl20 ];
    mainProgram = "lumine-capture";
    platforms = lib.platforms.linux;
  };
}
